'use strict';
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('incidencias', {
      id: { type: Sequelize.INTEGER, autoIncrement: true, primaryKey: true },
      titulo: { type: Sequelize.STRING(200), allowNull: false },
      descripcion: { type: Sequelize.TEXT, allowNull: false },
      categoria: { type: Sequelize.STRING(80), allowNull: true },
      prioridad: { type: Sequelize.ENUM('BAJA','MEDIA','ALTA','CRITICA'), allowNull: true },
      estatus: {
        type: Sequelize.ENUM('ABIERTA','EN_PROCESO','EN_ESPERA','RESUELTA','CERRADA'),
        allowNull: false, defaultValue: 'ABIERTA',
      },
      usuario_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'usuarios', key: 'id' }, onDelete: 'RESTRICT' },
      tecnico_id: { type: Sequelize.INTEGER, allowNull: true, references: { model: 'usuarios', key: 'id' }, onDelete: 'SET NULL' },
      activo: { type: Sequelize.BOOLEAN, defaultValue: true },
      fecha_creacion: { type: Sequelize.DATE, defaultValue: Sequelize.literal('NOW()') },
      fecha_cierre: { type: Sequelize.DATE, allowNull: true },
      created_at: { type: Sequelize.DATE, defaultValue: Sequelize.literal('NOW()') },
      updated_at: { type: Sequelize.DATE, defaultValue: Sequelize.literal('NOW()') },
    });
  },
  async down(queryInterface) {
    await queryInterface.dropTable('incidencias');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_incidencias_prioridad";');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_incidencias_estatus";');
  },
};
