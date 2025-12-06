const express = require('express');
const { Pool: PgPool } = require('pg');
const mysql = require('mysql2/promise');

const PORT = process.env.PORT || 3000;
const DB_CLIENT = (process.env.DB_CLIENT || 'postgres').toLowerCase();
const POSTGRES_URL = process.env.POSTGRES_URL || process.env.DATABASE_URL;
const MYSQL_URL = process.env.MYSQL_URL;

const app = express();
app.use(express.json());

const getPool = () => {
  if (DB_CLIENT === 'postgres') {
    if (!POSTGRES_URL) {
      throw new Error('Missing POSTGRES_URL (or DATABASE_URL) env var for Postgres connection');
    }
    return new PgPool({
      connectionString: POSTGRES_URL,
      ssl: { rejectUnauthorized: false }, // Heroku Postgres requires SSL
    });
  }

  if (DB_CLIENT === 'mysql') {
    if (!MYSQL_URL) {
      throw new Error('Missing MYSQL_URL env var for MySQL connection');
    }
    return mysql.createPool(MYSQL_URL);
  }

  throw new Error('Unsupported DB_CLIENT. Use "postgres" or "mysql".');
};

const pool = getPool();

const ensureTable = async () => {
  if (DB_CLIENT === 'postgres') {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS tasks (
        id SERIAL PRIMARY KEY,
        task TEXT NOT NULL,
        status BOOLEAN NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);
  } else {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS tasks (
        id INT AUTO_INCREMENT PRIMARY KEY,
        task TEXT NOT NULL,
        status BOOLEAN NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    `);
  }
};

app.post('/tasks', async (req, res) => {
  const { task, status } = req.body || {};

  if (typeof task !== 'string' || task.trim() === '') {
    return res.status(400).json({ error: '`task` must be a non-empty string' });
  }

  if (typeof status !== 'boolean') {
    return res.status(400).json({ error: '`status` must be a boolean' });
  }

  try {
    if (DB_CLIENT === 'postgres') {
      const result = await pool.query(
        'INSERT INTO tasks (task, status) VALUES ($1, $2) RETURNING id, task, status, created_at;',
        [task.trim(), status],
      );

      const row = result.rows[0];
      return res.status(201).json({
        message: 'Task saved',
        data: {
          id: row.id,
          task: row.task,
          status: row.status,
          createdAt: row.created_at,
        },
      });
    } else {
      const [insertResult] = await pool.query(
        'INSERT INTO tasks (task, status) VALUES (?, ?);',
        [task.trim(), status],
      );
      const insertedId = insertResult.insertId;
      const [rows] = await pool.query(
        'SELECT id, task, status, created_at FROM tasks WHERE id = ? LIMIT 1;',
        [insertedId],
      );
      const row = rows[0];

      return res.status(201).json({
        message: 'Task saved',
        data: {
          id: row.id,
          task: row.task,
          status: !!row.status,
          createdAt: row.created_at,
        },
      });
    }
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Failed to save task' });
  }
});

app.get('/tasks', async (_req, res) => {
  try {
    if (DB_CLIENT === 'postgres') {
      const result = await pool.query(
        'SELECT id, task, status, created_at FROM tasks ORDER BY id DESC;',
      );
      return res.json({
        data: result.rows.map((row) => ({
          id: row.id,
          task: row.task,
          status: row.status,
          createdAt: row.created_at,
        })),
      });
    } else {
      const [rows] = await pool.query(
        'SELECT id, task, status, created_at FROM tasks ORDER BY id DESC;',
      );
      return res.json({
        data: rows.map((row) => ({
          id: row.id,
          task: row.task,
          status: !!row.status,
          createdAt: row.created_at,
        })),
      });
    }
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

const start = async () => {
  try {
    await ensureTable();
    app.listen(PORT, () => {
      console.log(
        `API running at http://localhost:${PORT} using ${DB_CLIENT.toUpperCase()} storage`,
      );
    });
  } catch (err) {
    console.error('Failed to start server:', err.message);
    process.exit(1);
  }
};

start();
