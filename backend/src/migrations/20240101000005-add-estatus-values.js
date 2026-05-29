'use strict';
module.exports = {
  async up(queryInterface) {
    await queryInterface.sequelize.query(
      "ALTER TYPE enum_incidencias_estatus ADD VALUE IF NOT EXISTS 'EN_REVISION'"
    );
    await queryInterface.sequelize.query(
      "ALTER TYPE enum_incidencias_estatus ADD VALUE IF NOT EXISTS 'EN_DESARROLLO'"
    );
  },
  async down() {
    // PostgreSQL no permite eliminar valores de un ENUM sin recrearlo
  },
};
