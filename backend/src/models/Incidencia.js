'use strict';
const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const Incidencia = sequelize.define('Incidencia', {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  titulo: { type: DataTypes.STRING(200), allowNull: false },
  descripcion: { type: DataTypes.TEXT, allowNull: false },
  categoria: { type: DataTypes.STRING(80), allowNull: true },
  prioridad: { type: DataTypes.ENUM('BAJA','MEDIA','ALTA','CRITICA'), allowNull: true },
  estatus: { type: DataTypes.ENUM('ABIERTA','EN_PROCESO','EN_REVISION','EN_DESARROLLO','EN_ESPERA','RESUELTA','CERRADA'), allowNull: false, defaultValue: 'ABIERTA' },
  usuario_id: { type: DataTypes.INTEGER, allowNull: false },
  tecnico_id: { type: DataTypes.INTEGER, allowNull: true },
  activo: { type: DataTypes.BOOLEAN, defaultValue: true },
  fecha_creacion: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  fecha_cierre: { type: DataTypes.DATE, allowNull: true },
}, { tableName: 'incidencias', underscored: true, timestamps: true });

Incidencia.associate = (models) => {
  Incidencia.belongsTo(models.Usuario, { foreignKey: 'usuario_id', as: 'usuario' });
  Incidencia.belongsTo(models.Usuario, { foreignKey: 'tecnico_id', as: 'tecnico' });
  Incidencia.hasMany(models.IncidenciaLog, { foreignKey: 'incidencia_id', as: 'logs' });
  Incidencia.hasMany(models.Asignacion, { foreignKey: 'incidencia_id', as: 'asignaciones' });
};

module.exports = Incidencia;
