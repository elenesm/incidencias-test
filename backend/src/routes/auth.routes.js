'use strict';
const { Router } = require('express');
const { body } = require('express-validator');
const { login, logout } = require('../controllers/auth.controller');
const auth = require('../middlewares/auth.middleware');
const validate = require('../middlewares/validate.middleware');

const router = Router();

router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Email inválido.'),
    body('password').notEmpty().withMessage('Contraseña requerida.'),
    validate,
  ],
  login
);

router.post('/logout', auth, logout);

module.exports = router;
