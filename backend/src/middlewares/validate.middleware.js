'use strict';
const { validationResult } = require('express-validator');

const validateMiddleware = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({
      ok: false,
      message: 'Error de validación.',
      errors: errors.array(),
    });
  }
  next();
};

module.exports = validateMiddleware;
