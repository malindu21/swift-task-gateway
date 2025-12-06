const PORT = process.env.PORT || 3000;
const POSTGRES_URL = process.env.POSTGRES_URL || process.env.DATABASE_URL;
const USE_SSL = process.env.PG_SSL !== 'false';

if (!POSTGRES_URL) {
  throw new Error('Missing POSTGRES_URL (or DATABASE_URL) environment variable for Postgres connection');
}

module.exports = {
  PORT,
  POSTGRES_URL,
  USE_SSL,
};
