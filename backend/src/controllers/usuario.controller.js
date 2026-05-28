'use strict';
const { Incidencia, IncidenciaLog, Usuario } = require('../models');
const { Op } = require('sequelize');

const crearIncidencia = async (req, res, next) => {
  try {
    const { titulo, descripcion, categoria, prioridad } = req.body;
    const incidencia = await Incidencia.create({
      titulo, descripcion, categoria, prioridad,
      usuario_id: req.user.id,
      estatus: 'ABIERTA',
    });
    await IncidenciaLog.create({
      incidencia_id: incidencia.id,
      autor_id: req.user.id,
      mensaje: 'Incidencia creada.',
      estatus_nuevo: 'ABIERTA',
    });
    return res.status(201).json({ ok: true, incidencia });
  } catch (err) { next(err); }
};

const listarMisIncidencias = async (req, res, next) => {
  try {
    const where = { usuario_id: req.user.id, activo: true };
    if (req.query.estatus) where.estatus = req.query.estatus;
    const incidencias = await Incidencia.findAll({
      where,
      include: [{ model: Usuario, as: 'tecnico', attributes: ['id', 'nombre', 'email'] }],
      order: [['created_at', 'DESC']],
    });
    return res.json({ ok: true, incidencias });
  } catch (err) { next(err); }
};

const detalleIncidencia = async (req, res, next) => {
  try {
    const incidencia = await Incidencia.findOne({
      where: { id: req.params.id, usuario_id: req.user.id, activo: true },
      include: [
        { model: Usuario, as: 'tecnico', attributes: ['id', 'nombre', 'email'] },
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
    const incidencia = await Incidencia.findOne({
      where: { id: req.params.id, usuario_id: req.user.id, activo: true },
    });
    if (!incidencia) return res.status(404).json({ ok: false, message: 'Incidencia no encontrada.' });
    const log = await IncidenciaLog.create({
      incidencia_id: incidencia.id,
      autor_id: req.user.id,
      mensaje: req.body.mensaje,
    });
    return res.status(201).json({ ok: true, log });
  } catch (err) { next(err); }
};

module.exports = { crearIncidencia, listarMisIncidencias, detalleIncidencia, agregarComentario };
