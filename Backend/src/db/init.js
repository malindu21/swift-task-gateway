const pool = require('./pool');

const ensureSchema = async () => {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS tasks (
      id SERIAL PRIMARY KEY,
      task TEXT NOT NULL,
      status BOOLEAN NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);
};

module.exports = { ensureSchema };
