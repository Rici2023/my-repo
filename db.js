import sqlite3 from 'sqlite3';
import { open } from 'sqlite';
import path from 'path';
import fs from 'fs';

const dbPath = process.env.DB_PATH || './data/app.db';
fs.mkdirSync(path.dirname(dbPath), { recursive: true });

export async function getDb() {
  const db = await open({ filename: dbPath, driver: sqlite3.Database });
  await db.exec(`PRAGMA foreign_keys = ON;`);
  return db;
}

export async function migrate(db) {
  await db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      role TEXT NOT NULL DEFAULT 'user',
      created_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS roles (
      id TEXT PRIMARY KEY,
      name TEXT UNIQUE NOT NULL,
      permissions TEXT NOT NULL DEFAULT '[]'
    );

    CREATE TABLE IF NOT EXISTS activities (
      id TEXT PRIMARY KEY,
      type TEXT NOT NULL,
      title TEXT NOT NULL,
      status TEXT NOT NULL,
      amount REAL DEFAULT 0,
      created_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS invoices (
      id TEXT PRIMARY KEY,
      customer TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL DEFAULT 'USD',
      status TEXT NOT NULL CHECK(status IN ('Paid','Due','Overdue')),
      issued_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS agents_health (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      uptime REAL NOT NULL,
      slo REAL NOT NULL,
      last_check TEXT NOT NULL,
      status TEXT NOT NULL CHECK(status IN ('OK','WARN','DOWN'))
    );

    CREATE TABLE IF NOT EXISTS kpis (
      id TEXT PRIMARY KEY,
      label TEXT NOT NULL,
      value REAL NOT NULL,
      delta REAL NOT NULL,
      segment JSON
    );
  `);
}
