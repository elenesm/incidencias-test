'use strict';
const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const IncidenciaLog = sequelize.define('IncidenciaLog', {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  incidencia_id: { type: DataTypes.INTEGER, allowNull: false },
  autor_id: { type: DataTypes.INTEGER, allowNull: false },
  mensaje: { type: DataTypes.TEXT, allowNull: false },
  estatus_nuevo: { type: DataTypes.STRING(30), allowNull: true },
}, { tableName: 'incidencia_logs', underscored: true, timestamps: true, updatedAt: false });

IncidenciaLog.associate = (models) => {
  IncidenciaLog.belongsTo(models.Incidencia, { foreignKey: 'incidencia_id', as: 'incidencia' });
  IncidenciaLog.belongsTo(models.Usuario, { foreignKey: 'autor_id', as: 'autor' });
};

module.exports = IncidenciaLog;
