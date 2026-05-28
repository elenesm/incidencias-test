'use strict';
const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const Usuario = sequelize.define('Usuario', {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  nombre: { type: DataTypes.STRING(120), allowNull: false },
  email: { type: DataTypes.STRING(255), allowNull: false, unique: true },
  password_hash: { type: DataTypes.STRING(255), allowNull: false },
  rol: { type: DataTypes.ENUM('USUARIO','TECNICO','SUPERVISOR'), allowNull: false },
}, { tableName: 'usuarios', underscored: true, timestamps: true });

Usuario.associate = (models) => {
  Usuario.hasMany(models.Incidencia, { foreignKey: 'usuario_id', as: 'incidenciasCreadas' });
  Usuario.hasMany(models.Incidencia, { foreignKey: 'tecnico_id', as: 'incidenciasAsignadas' });
  Usuario.hasMany(models.IncidenciaLog, { foreignKey: 'autor_id', as: 'logs' });
};

module.exports = Usuario;
