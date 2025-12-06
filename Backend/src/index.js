const app = require('./app');
const { ensureSchema } = require('./db/init');
const { PORT } = require('./config/env');

const start = async () => {
  try {
    await ensureSchema();
    app.listen(PORT, () => {
      console.log(`API running at http://localhost:${PORT} using Postgres storage`);
    });
  } catch (err) {
    console.error('Failed to start server:', err.message);
    process.exit(1);
  }
};

start();
