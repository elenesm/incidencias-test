'use strict';
const { Incidencia, IncidenciaLog, Usuario } = require('../models');

const listarAsignadas = async (req, res, next) => {
  try {
    const where = { tecnico_id: req.user.id, activo: true };
    if (req.query.estatus) where.estatus = req.query.estatus;
    const incidencias = await Incidencia.findAll({
      where,
      include: [{ model: Usuario, as: 'usuario', attributes: ['id', 'nombre', 'email'] }],
      order: [['created_at', 'DESC']],
    });
    return res.json({ ok: true, incidencias });
  } catch (err) { next(err); }
};

const detalleAsignada = async (req, res, next) => {
  try {
    const incidencia = await Incidencia.findOne({
      where: { id: req.params.id, tecnico_id: req.user.id, activo: true },
      include: [
        { model: Usuario, as: 'usuario', attributes: ['id', 'nombre', 'email'] },
        { model: IncidenciaLog, as: 'logs',
          include: [{ model: Usuario, as: 'autor', attributes: ['id', 'nombre', 'rol'] }] },
      ],
    });
    if (!incidencia) return res.status(404).json({ ok: false, message: 'Incidencia no encontrada.' });
    return res.json({ ok: true, incidencia });
  } catch (err) { next(err); }
};

const actualizarEstatus = async (req, res, next) => {
  try {
    const incidencia = await Incidencia.findOne({
      where: { id: req.params.id, tecnico_id: req.user.id, activo: true },
    });
    if (!incidencia) return res.status(404).json({ ok: false, message: 'Incidencia no encontrada.' });

    const { estatus, comentario } = req.body;
    const updates = {};
    if (estatus) updates.estatus = estatus;
    if (estatus === 'RESUELTA' || estatus === 'CERRADA') updates.fecha_cierre = new Date();
    await incidencia.update(updates);

    const mensajeLog = comentario || `Estatus actualizado a ${estatus}.`;
    await IncidenciaLog.create({
      incidencia_id: incidencia.id,
      autor_id: req.user.id,
      mensaje: mensajeLog,
      estatus_nuevo: estatus || null,
    });

    return res.json({ ok: true, incidencia });
  } catch (err) { next(err); }
};

const agregarComentario = async (req, res, next) => {
  try {
    const incidencia = await Incidencia.findOne({
      where: { id: req.params.id, tecnico_id: req.user.id, activo: true },
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

module.exports = { listarAsignadas, detalleAsignada, actualizarEstatus, agregarComentario };
