'use strict';
const Usuario = require('./Usuario');
const Incidencia = require('./Incidencia');
const IncidenciaLog = require('./IncidenciaLog');
const Asignacion = require('./Asignacion');

const models = { Usuario, Incidencia, IncidenciaLog, Asignacion };

Object.values(models).forEach((model) => {
  if (typeof model.associate === 'function') model.associate(models);
});

module.exports = models;
