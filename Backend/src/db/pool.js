const { Pool } = require('pg');
const { POSTGRES_URL, USE_SSL } = require('../config/env');

const pool = new Pool({
  connectionString: POSTGRES_URL,
  ssl: USE_SSL ? { rejectUnauthorized: false } : false,
});

module.exports = pool;
