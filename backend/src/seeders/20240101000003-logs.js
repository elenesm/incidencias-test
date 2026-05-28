'use strict';

module.exports = {
  async up(queryInterface) {
    const incidencias = await queryInterface.sequelize.query(
      'SELECT id FROM incidencias ORDER BY id ASC LIMIT 5',
      { type: queryInterface.sequelize.QueryTypes.SELECT }
    );
    const usuarios = await queryInterface.sequelize.query(
      'SELECT id, rol FROM usuarios ORDER BY id ASC',
      { type: queryInterface.sequelize.QueryTypes.SELECT }
    );
    const supervisor = usuarios.find(u => u.rol === 'SUPERVISOR');
    const tecnico = usuarios.find(u => u.rol === 'TECNICO');
    const usuario = usuarios.find(u => u.rol === 'USUARIO');
    const ahora = new Date();

    const logs = [];
    incidencias.forEach((inc, i) => {
      logs.push({ incidencia_id: inc.id, autor_id: usuario.id, mensaje: 'Incidencia reportada por el usuario.', estatus_nuevo: 'ABIERTA', created_at: ahora });
      if (i < 3) logs.push({ incidencia_id: inc.id, autor_id: supervisor.id, mensaje: 'Asignada al técnico correspondiente.', estatus_nuevo: 'EN_PROCESO', created_at: ahora });
      if (i < 2) logs.push({ incidencia_id: inc.id, autor_id: tecnico.id, mensaje: 'Revisando el problema, se detectó la causa raíz.', estatus_nuevo: null, created_at: ahora });
    });

    await queryInterface.bulkInsert('incidencia_logs', logs, {});
  },
  async down(queryInterface) {
    await queryInterface.bulkDelete('incidencia_logs', null, {});
  },
};
