'use strict';
const { Router } = require('express');
const { body, param } = require('express-validator');
const ctrl = require('../controllers/tecnico.controller');
const auth = require('../middlewares/auth.middleware');
const role = require('../middlewares/role.middleware');
const validate = require('../middlewares/validate.middleware');

const router = Router();

router.use(auth, role('TECNICO'));

router.get('/incidencias', ctrl.listarAsignadas);
router.get('/incidencias/:id', [param('id').isInt(), validate], ctrl.detalleAsignada);
router.patch(
  '/incidencias/:id',
  [param('id').isInt(), body('estatus').optional().isIn(['EN_PROCESO','EN_ESPERA','RESUELTA']), validate],
  ctrl.actualizarEstatus
);
router.post(
  '/incidencias/:id/comentarios',
  [param('id').isInt(), body('mensaje').notEmpty(), validate],
  ctrl.agregarComentario
);

module.exports = router;
