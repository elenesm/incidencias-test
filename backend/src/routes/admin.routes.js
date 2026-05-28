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
  '/incidencias/:id/asignar',
  [param('id').isInt(), body('tecnico_id').isInt().withMessage('tecnico_id requerido.'), validate],
  ctrl.asignarTecnico
);
router.patch('/incidencias/:id', [param('id').isInt(), validate], ctrl.actualizarCampos);
router.delete('/incidencias/:id', [param('id').isInt(), validate], ctrl.inactivarIncidencia);
router.get('/reportes', ctrl.reportes);

module.exports = router;
