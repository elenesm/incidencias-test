'use strict';
const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const Asignacion = sequelize.define('Asignacion', {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  incidencia_id: { type: DataTypes.INTEGER, allowNull: false },
  tecnico_id: { type: DataTypes.INTEGER, allowNull: false },
  asignado_por: { type: DataTypes.INTEGER, allowNull: false },
}, { tableName: 'asignaciones', underscored: true, timestamps: true, updatedAt: false });

Asignacion.associate = (models) => {
  Asignacion.belongsTo(models.Incidencia, { foreignKey: 'incidencia_id', as: 'incidencia' });
  Asignacion.belongsTo(models.Usuario, { foreignKey: 'tecnico_id', as: 'tecnico' });
  Asignacion.belongsTo(models.Usuario, { foreignKey: 'asignado_por', as: 'supervisor' });
};

module.exports = Asignacion;
