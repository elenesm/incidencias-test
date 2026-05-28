'use strict';
const { Router } = require('express');
const { body, param, query } = require('express-validator');
const ctrl = require('../controllers/usuario.controller');
const auth = require('../middlewares/auth.middleware');
const role = require('../middlewares/role.middleware');
const validate = require('../middlewares/validate.middleware');

const router = Router();

router.use(auth, role('USUARIO'));

router.post(
  '/incidencias',
  [body('titulo').notEmpty(), body('descripcion').notEmpty(), validate],
  ctrl.crearIncidencia
);
router.get(
  '/incidencias',
  [
    query('estatus')
      .optional()
      .isIn(['ABIERTA', 'EN_PROCESO', 'EN_ESPERA', 'RESUELTA', 'CERRADA'])
      .withMessage('Estatus inválido.'),
    validate,
  ],
  ctrl.listarMisIncidencias
);
router.get('/incidencias/:id', [param('id').isInt(), validate], ctrl.detalleIncidencia);
router.post(
  '/incidencias/:id/comentarios',
  [param('id').isInt(), body('mensaje').notEmpty(), validate],
  ctrl.agregarComentario
);

module.exports = router;
