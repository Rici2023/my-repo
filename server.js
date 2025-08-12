import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import cookieParser from 'cookie-parser';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { nanoid } from 'nanoid';
import { getDb, migrate } from './db.js';

const app = express();
const PORT = process.env.PORT || 3001;
const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret';
const ORIGIN = process.env.CORS_ORIGIN || '*';
const COOKIE_SECURE = String(process.env.COOKIE_SECURE) === 'true';

app.use(helmet());
app.use(express.json());
app.use(cookieParser());
app.use(cors({ origin: ORIGIN.split(','), credentials: true }));

function auth(requiredRole = null) {
  return (req, res, next) => {
    const token = req.cookies?.token || (req.headers.authorization?.split(' ')[1]);
    if (!token) return res.status(401).json({ error: 'Unauthorized' });
    try {
      const payload = jwt.verify(token, JWT_SECRET);
      req.user = payload;
      if (requiredRole && payload.role !== requiredRole && payload.role !== 'admin') {
        return res.status(403).json({ error: 'Forbidden' });
      }
      next();
    } catch (e) { return res.status(401).json({ error: 'Invalid token' }); }
  };
}

// DB init
let db;
(async () => { db = await getDb(); await migrate(db); })();

// ── Auth ──────────────────────────────────────────
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password) return res.status(400).json({ error: 'Missing creds' });
  const user = await db.get('SELECT * FROM users WHERE email = ?', email);
  if (!user) return res.status(401).json({ error: 'Invalid creds' });
  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) return res.status(401).json({ error: 'Invalid creds' });
  const token = jwt.sign({ id: user.id, email, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
  res.cookie('token', token, { httpOnly: true, sameSite: 'lax', secure: COOKIE_SECURE, maxAge: 7*24*3600*1000 });
  res.json({ ok: true, role: user.role });
});

app.post('/api/auth/logout', (req, res) => {
  res.clearCookie('token');
  res.json({ ok: true });
});

app.get('/api/auth/me', auth(), async (req, res) => {
  const user = await db.get('SELECT id,email,role,created_at FROM users WHERE id = ?', req.user.id);
  res.json(user);
});

// ── KPI & Drilldown ───────────────────────────────
app.get('/api/kpis', auth(), async (req, res) => {
  const list = await db.all('SELECT * FROM kpis');
  res.json(list.map(k => ({ ...k, segment: k.segment ? JSON.parse(k.segment) : null })));
});

// ── Finance with filters/pagination ──────────────
app.get('/api/finance/invoices', auth(), async (req, res) => {
  const { page = 1, pageSize = 20, dateFrom, dateTo, status, q, sort = 'issued_at', order = 'DESC' } = req.query;
  const ps = Math.min(Math.max(parseInt(pageSize,10)||20, 1), 200);
  const p = Math.max(parseInt(page,10)||1, 1);
  const offset = (p-1)*ps;

  const where = [];
  const params = [];
  if (dateFrom) { where.push('issued_at >= ?'); params.push(new Date(dateFrom).toISOString()); }
  if (dateTo)   { where.push('issued_at <= ?'); params.push(new Date(dateTo).toISOString()); }
  if (status)   { where.push('status = ?'); params.push(status); }
  if (q)        { where.push('customer LIKE ?'); params.push(`%${q}%`); }

  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const allowedSort = new Set(['issued_at','amount','customer','status']);
  const s = allowedSort.has(String(sort)) ? String(sort) : 'issued_at';
  const o = String(order).toUpperCase() === 'ASC' ? 'ASC' : 'DESC';

  const totalRow = await db.get(`SELECT COUNT(*) as cnt FROM invoices ${whereSql}`, params);
  const rows = await db.all(
    `SELECT * FROM invoices ${whereSql} ORDER BY ${s} ${o} LIMIT ? OFFSET ?`,
    ...params, ps, offset
  );
  res.json({ rows, page: p, pageSize: ps, total: totalRow.cnt, pages: Math.ceil(totalRow.cnt/ps) });
});

// ── Activities with filters/pagination ───────────
app.get('/api/activities', auth(), async (req, res) => {
  const { page = 1, pageSize = 20, dateFrom, dateTo, type, status, sort = 'created_at', order = 'DESC' } = req.query;
  const ps = Math.min(Math.max(parseInt(pageSize,10)||20, 1), 200);
  const p = Math.max(parseInt(page,10)||1, 1);
  const offset = (p-1)*ps;

  const where = [];
  const params = [];
  if (dateFrom) { where.push('created_at >= ?'); params.push(new Date(dateFrom).toISOString()); }
  if (dateTo)   { where.push('created_at <= ?'); params.push(new Date(dateTo).toISOString()); }
  if (type)     { where.push('type = ?'); params.push(type); }
  if (status)   { where.push('status = ?'); params.push(status); }

  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const allowedSort = new Set(['created_at','amount','type','status']);
  const s = allowedSort.has(String(sort)) ? String(sort) : 'created_at';
  const o = String(order).toUpperCase() === 'ASC' ? 'ASC' : 'DESC';

  const totalRow = await db.get(`SELECT COUNT(*) as cnt FROM activities ${whereSql}`, params);
  const rows = await db.all(
    `SELECT * FROM activities ${whereSql} ORDER BY ${s} ${o} LIMIT ? OFFSET ?`,
    ...params, ps, offset
  );
  res.json({ rows, page: p, pageSize: ps, total: totalRow.cnt, pages: Math.ceil(totalRow.cnt/ps) });
});

// ── Agents Health ─────────────────────────────────
app.get('/api/agents/health', auth(), async (req, res) => {
  const rows = await db.all('SELECT * FROM agents_health ORDER BY name');
  res.json(rows);
});

// ── Roles (Admin) ─────────────────────────────────
app.get('/api/roles', auth('admin'), async (req, res) => {
  const rows = await db.all('SELECT * FROM roles');
  res.json(rows.map(r => ({ ...r, permissions: JSON.parse(r.permissions) })));
});

app.post('/api/roles', auth('admin'), async (req, res) => {
  const { name, permissions = [] } = req.body;
  const id = nanoid();
  try {
    await db.run('INSERT INTO roles (id,name,permissions) VALUES (?,?,?)', id, name, JSON.stringify(permissions));
    res.json({ id, name, permissions });
  } catch (e) { res.status(400).json({ error: e.message }); }
});

app.delete('/api/roles/:id', auth('admin'), async (req, res) => {
  await db.run('DELETE FROM roles WHERE id = ?', req.params.id);
  res.json({ ok: true });
});

// ── Utility: healthcheck ──────────────────────────
app.get('/api/health', (_req, res) => { res.json({ ok: true }); });

app.listen(PORT, () => console.log(`API listening on :${PORT}`));
