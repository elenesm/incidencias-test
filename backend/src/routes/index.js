'use strict';
const { Router } = require('express');
const authRoutes = require('./auth.routes');
const usuarioRoutes = require('./usuario.routes');
const tecnicoRoutes = require('./tecnico.routes');
const adminRoutes = require('./admin.routes');

const router = Router();

router.use('/auth', authRoutes);
router.use('/usuario', usuarioRoutes);
router.use('/tecnico', tecnicoRoutes);
router.use('/admin', adminRoutes);

module.exports = router;
