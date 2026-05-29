'use strict';
const { Router } = require('express');
const { body, param } = require('express-validator');
const ctrl = require('../controllers/admin.controller');
const auth = require('../middlewares/auth.middleware');
const role = require('../middlewares/role.middleware');
const validate = require('../middlewares/validate.middleware');

const router = Router();

router.use(auth, role('SUPERVISOR'));

router.get('/incidencias', ctrl.listarTodas);
router.post(
  '/incidencias',
  [
    body('titulo').notEmpty().withMessage('Título requerido.'),
    body('descripcion').notEmpty().withMessage('Descripción requerida.'),
    body('usuario_id').isInt().withMessage('usuario_id requerido.'),
    body('tecnico_id').optional().isInt(),
    validate,
  ],
  ctrl.crearIncidencia
);
router.get('/tecnicos', ctrl.listarTecnicos);
router.get('/usuarios', ctrl.listarUsuarios);
router.post(
  '/incidencias/:id/asignar',
  [param('id').isInt(), body('tecnico_id').isInt().withMessage('tecnico_id requerido.'), validate],
  ctrl.asignarTecnico
);
router.patch('/incidencias/:id', [param('id').isInt(), validate], ctrl.actualizarCampos);
router.delete('/incidencias/:id', [param('id').isInt(), validate], ctrl.inactivarIncidencia);
router.post(
  '/incidencias/:id/comentarios',
  [param('id').isInt(), body('mensaje').notEmpty(), validate],
  ctrl.agregarComentario
);
router.get('/reportes', ctrl.reportes);

module.exports = router;
