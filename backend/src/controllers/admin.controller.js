'use strict';
const { Incidencia, IncidenciaLog, Usuario, Asignacion } = require('../models');
const { Op, fn, col, literal } = require('sequelize');

const listarTodas = async (req, res, next) => {
  try {
    const where = { activo: true };
    const { estatus, prioridad, tecnico_id, desde, hasta } = req.query;
    if (estatus) where.estatus = estatus;
    if (prioridad) where.prioridad = prioridad;
    if (tecnico_id) where.tecnico_id = tecnico_id;
    if (desde || hasta) {
      where.fecha_creacion = {};
      if (desde) where.fecha_creacion[Op.gte] = new Date(desde);
      if (hasta) where.fecha_creacion[Op.lte] = new Date(hasta);
    }
    const incidencias = await Incidencia.findAll({
      where,
      include: [
        { model: Usuario, as: 'usuario', attributes: ['id', 'nombre', 'email'] },
        { model: Usuario, as: 'tecnico', attributes: ['id', 'nombre', 'email'] },
      ],
      order: [['created_at', 'DESC']],
    });
    return res.json({ ok: true, incidencias });
  } catch (err) { next(err); }
};

const asignarTecnico = async (req, res, next) => {
  try {
    const incidencia = await Incidencia.findOne({ where: { id: req.params.id, activo: true } });
    if (!incidencia) return res.status(404).json({ ok: false, message: 'Incidencia no encontrada.' });

    const tecnico = await Usuario.findOne({ where: { id: req.body.tecnico_id, rol: 'TECNICO' } });
    if (!tecnico) return res.status(404).json({ ok: false, message: 'Técnico no encontrado.' });

    await incidencia.update({ tecnico_id: tecnico.id, estatus: 'EN_PROCESO' });

    await Asignacion.create({
      incidencia_id: incidencia.id,
      tecnico_id: tecnico.id,
      asignado_por: req.user.id,
    });

    await IncidenciaLog.create({
      incidencia_id: incidencia.id,
      autor_id: req.user.id,
      mensaje: `Incidencia asignada al técnico ${tecnico.nombre}.`,
      estatus_nuevo: 'EN_PROCESO',
    });

    return res.json({ ok: true, message: 'Técnico asignado correctamente.', incidencia });
  } catch (err) { next(err); }
};

const actualizarCampos = async (req, res, next) => {
  try {
    const incidencia = await Incidencia.findOne({ where: { id: req.params.id, activo: true } });
    if (!incidencia) return res.status(404).json({ ok: false, message: 'Incidencia no encontrada.' });

    const camposPermitidos = ['prioridad', 'categoria', 'estatus', 'titulo', 'descripcion'];
    const updates = {};
    camposPermitidos.forEach((campo) => {
      if (req.body[campo] !== undefined) updates[campo] = req.body[campo];
    });

    await incidencia.update(updates);
    await IncidenciaLog.create({
      incidencia_id: incidencia.id,
      autor_id: req.user.id,
      mensaje: `Supervisor actualizó campos: ${Object.keys(updates).join(', ')}.`,
      estatus_nuevo: updates.estatus || null,
    });

    return res.json({ ok: true, incidencia });
  } catch (err) { next(err); }
};

const inactivarIncidencia = async (req, res, next) => {
  try {
    const incidencia = await Incidencia.findOne({ where: { id: req.params.id, activo: true } });
    if (!incidencia) return res.status(404).json({ ok: false, message: 'Incidencia no encontrada.' });

    await incidencia.update({ activo: false });
    await IncidenciaLog.create({
      incidencia_id: incidencia.id,
      autor_id: req.user.id,
      mensaje: 'Incidencia inactivada por supervisor (soft delete).',
    });

    return res.json({ ok: true, message: 'Incidencia inactivada correctamente.' });
  } catch (err) { next(err); }
};

const reportes = async (req, res, next) => {
  try {
    const { desde, hasta } = req.query;
    const whereFecha = {};
    if (desde) whereFecha[Op.gte] = new Date(desde);
    if (hasta) whereFecha[Op.lte] = new Date(hasta);

    // Por estatus
    const porEstatus = await Incidencia.findAll({
      attributes: ['estatus', [fn('COUNT', col('id')), 'total']],
      where: Object.keys(whereFecha).length ? { fecha_creacion: whereFecha } : {},
      group: ['estatus'],
      raw: true,
    });

    // Por prioridad
    const porPrioridad = await Incidencia.findAll({
      attributes: ['prioridad', [fn('COUNT', col('id')), 'total']],
      where: Object.keys(whereFecha).length ? { fecha_creacion: whereFecha } : {},
      group: ['prioridad'],
      raw: true,
    });

    // Por técnico
    const porTecnico = await Incidencia.findAll({
      attributes: [
        'tecnico_id',
        [fn('COUNT', col('Incidencia.id')), 'total'],
      ],
      include: [{ model: Usuario, as: 'tecnico', attributes: ['nombre', 'email'] }],
      where: { tecnico_id: { [Op.ne]: null }, ...(Object.keys(whereFecha).length ? { fecha_creacion: whereFecha } : {}) },
      group: ['tecnico_id', 'tecnico.id'],
      raw: true,
      nest: true,
    });

    return res.json({ ok: true, reportes: { porEstatus, porPrioridad, porTecnico } });
  } catch (err) { next(err); }
};

const listarTecnicos = async (req, res, next) => {
  try {
    const tecnicos = await Usuario.findAll({
      where: { rol: 'TECNICO' },
      attributes: ['id', 'nombre', 'email'],
      order: [['nombre', 'ASC']],
    });
    return res.json({ ok: true, tecnicos });
  } catch (err) { next(err); }
};

const listarUsuarios = async (req, res, next) => {
  try {
    const usuarios = await Usuario.findAll({
      where: { rol: 'USUARIO' },
      attributes: ['id', 'nombre', 'email'],
      order: [['nombre', 'ASC']],
    });
    return res.json({ ok: true, usuarios });
  } catch (err) { next(err); }
};

const crearIncidencia = async (req, res, next) => {
  try {
    const { titulo, descripcion, categoria, prioridad, usuario_id, tecnico_id } = req.body;

    const usuario = await Usuario.findOne({ where: { id: usuario_id, rol: 'USUARIO' } });
    if (!usuario) return res.status(404).json({ ok: false, message: 'Usuario no encontrado.' });

    const incidencia = await Incidencia.create({
      titulo, descripcion, categoria, prioridad,
      usuario_id,
      tecnico_id: tecnico_id || null,
      estatus: tecnico_id ? 'EN_PROCESO' : 'ABIERTA',
    });

    if (tecnico_id) {
      await Asignacion.create({ incidencia_id: incidencia.id, tecnico_id, asignado_por: req.user.id });
    }

    await IncidenciaLog.create({
      incidencia_id: incidencia.id,
      autor_id: req.user.id,
      mensaje: tecnico_id
        ? `Incidencia creada por supervisor y asignada al técnico.`
        : `Incidencia creada por supervisor.`,
      estatus_nuevo: incidencia.estatus,
    });

    return res.status(201).json({ ok: true, incidencia });
  } catch (err) { next(err); }
};

const detalleIncidencia = async (req, res, next) => {
  try {
    const incidencia = await Incidencia.findOne({
      where: { id: req.params.id, activo: true },
      include: [
        { model: Usuario, as: 'usuario', attributes: ['id', 'nombre', 'email'] },
        { model: Usuario, as: 'tecnico',  attributes: ['id', 'nombre', 'email'] },
        { model: IncidenciaLog, as: 'logs',
          include: [{ model: Usuario, as: 'autor', attributes: ['id', 'nombre', 'email', 'rol'] }],
          order: [['created_at', 'ASC']] },
      ],
    });
    if (!incidencia) return res.status(404).json({ ok: false, message: 'Incidencia no encontrada.' });
    return res.json({ ok: true, incidencia });
  } catch (err) { next(err); }
};

const agregarComentario = async (req, res, next) => {
  try {
    const incidencia = await Incidencia.findOne({ where: { id: req.params.id, activo: true } });
    if (!incidencia) return res.status(404).json({ ok: false, message: 'Incidencia no encontrada.' });
    const log = await IncidenciaLog.create({
      incidencia_id: incidencia.id,
      autor_id: req.user.id,
      mensaje: req.body.mensaje,
    });
    return res.status(201).json({ ok: true, log });
  } catch (err) { next(err); }
};

module.exports = {
  listarTodas, detalleIncidencia, asignarTecnico, actualizarCampos,
  inactivarIncidencia, reportes, listarTecnicos, listarUsuarios,
  crearIncidencia, agregarComentario,
};
