'use strict';

const errorMiddleware = (err, req, res, next) => {
  console.error('[ERROR]', err.message);

  const status = err.status || 500;
  const message = err.message || 'Error interno del servidor.';

  return res.status(status).json({ ok: false, message });
};

module.exports = errorMiddleware;
