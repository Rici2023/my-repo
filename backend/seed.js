import 'dotenv/config';
import { getDb, migrate } from '../db.js';
import bcrypt from 'bcryptjs';
import { nanoid } from 'nanoid';

const now = () => new Date().toISOString();

async function main() {
  const db = await getDb();
  await migrate(db);

  // Users
  const adminEmail = 'admin@demo.local';
  const userEmail = 'user@demo.local';
  const adminPass = await bcrypt.hash('admin123', 10);
  const userPass = await bcrypt.hash('user123', 10);

  await db.run(`INSERT OR IGNORE INTO users (id,email,password_hash,role,created_at) VALUES
    (?,?,?,?,?), (?,?,?,?,?)`,
    nanoid(), adminEmail, adminPass, 'admin', now(),
    nanoid(), userEmail, userPass, 'user', now()
  );

  // Roles
  await db.run(`INSERT OR IGNORE INTO roles (id,name,permissions) VALUES
    (?,?,?), (?,?,?), (?,?,?)`,
    nanoid(), 'Admin', JSON.stringify(['*']),
    nanoid(), 'Finance', JSON.stringify(['finance:read']),
    nanoid(), 'Ops', JSON.stringify(['agents:read','activities:read'])
  );

  // KPIs
  const kpis = [
    { label: 'MRR', value: 32500, delta: 7.2, segment: { Enterprise: 55, SMB: 35, Indie: 10 } },
    { label: 'Active Users', value: 4820, delta: 3.1, segment: { Web: 70, Mobile: 30 } },
    { label: 'Churn', value: 2.3, delta: -0.4, segment: { Voluntary: 1.2, Involuntary: 1.1 } },
    { label: 'NPS', value: 62, delta: 1.8, segment: { Promoters: 68, Passives: 22, Detractors: 10 } }
  ];
  for (const k of kpis) {
    await db.run('INSERT OR IGNORE INTO kpis (id,label,value,delta,segment) VALUES (?,?,?,?,?)',
      nanoid(), k.label, k.value, k.delta, JSON.stringify(k.segment));
  }

  // Invoices
  for (let i=0; i<24; i++) {
    const amt = Math.round((Math.random()*4000+500) * 100)/100;
    const statuses = ['Paid','Due','Overdue'];
    const status = statuses[Math.floor(Math.random()*statuses.length)];
    await db.run('INSERT OR IGNORE INTO invoices (id,customer,amount,currency,status,issued_at) VALUES (?,?,?,?,?,?)',
      nanoid(), `Customer ${i+1}`, amt, 'USD', status, new Date(Date.now()-i*86400000).toISOString());
  }

  // Activities
  const types = ['deal','payment','support','deploy'];
  const statuses = ['OK','WARN','Pending'];
  for (let i=0; i<32; i++) {
    await db.run('INSERT OR IGNORE INTO activities (id,type,title,status,amount,created_at) VALUES (?,?,?,?,?,?)',
      nanoid(), types[i%types.length], `Activity ${i+1}`, statuses[i%statuses.length], Math.round(Math.random()*2000), new Date(Date.now()-i*3600000).toISOString());
  }

  // Agents health
  const agents = [
    { name: 'BillingBot' }, { name: 'NLP-Summarizer' }, { name: 'Alerting' }, { name: 'Imports' }
  ];
  for (const a of agents) {
    const uptime = Math.round((Math.random()*5+99)*100)/100;
    const slo = Math.round((Math.random()*5+95)*100)/100;
    const stList = ['OK','WARN','DOWN'];
    const status = stList[Math.floor(Math.random()*stList.length-0.2)] || 'OK';
    await db.run('INSERT OR IGNORE INTO agents_health (id,name,uptime,slo,last_check,status) VALUES (?,?,?,?,?,?)',
      nanoid(), a.name, uptime, slo, now(), status);
  }

  console.log('Seed completed.');
  await db.close();
}

main().catch(e => { console.error(e); process.exit(1); });
