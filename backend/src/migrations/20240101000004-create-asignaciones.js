'use strict';
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('asignaciones', {
      id: { type: Sequelize.INTEGER, autoIncrement: true, primaryKey: true },
      incidencia_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'incidencias', key: 'id' }, onDelete: 'CASCADE' },
      tecnico_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'usuarios', key: 'id' }, onDelete: 'RESTRICT' },
      asignado_por: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'usuarios', key: 'id' }, onDelete: 'RESTRICT' },
      created_at: { type: Sequelize.DATE, defaultValue: Sequelize.literal('NOW()') },
    });
  },
  async down(queryInterface) {
    await queryInterface.dropTable('asignaciones');
  },
};
