const notFound = (_req, res) => {
  res.status(404).json({ error: 'Not found' });
};

// eslint-disable-next-line no-unused-vars
const errorHandler = (err, _req, res, _next) => {
  console.error(err);
  const status = err.status || 500;
  const message = err.message || 'Internal server error';
  res.status(status).json({ error: message });
};

module.exports = {
  notFound,
  errorHandler,
};
