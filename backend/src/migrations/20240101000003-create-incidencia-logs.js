'use strict';
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('incidencia_logs', {
      id: { type: Sequelize.INTEGER, autoIncrement: true, primaryKey: true },
      incidencia_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'incidencias', key: 'id' }, onDelete: 'CASCADE' },
      autor_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'usuarios', key: 'id' }, onDelete: 'RESTRICT' },
      mensaje: { type: Sequelize.TEXT, allowNull: false },
      estatus_nuevo: { type: Sequelize.STRING(30), allowNull: true },
      created_at: { type: Sequelize.DATE, defaultValue: Sequelize.literal('NOW()') },
    });
  },
  async down(queryInterface) {
    await queryInterface.dropTable('incidencia_logs');
  },
};
