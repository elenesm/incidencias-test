'use strict';

module.exports = {
  async up(queryInterface) {
    // Obtenemos IDs de usuarios
    const usuarios = await queryInterface.sequelize.query(
      'SELECT id, rol FROM usuarios ORDER BY id ASC',
      { type: queryInterface.sequelize.QueryTypes.SELECT }
    );
    const supervisor = usuarios.find(u => u.rol === 'SUPERVISOR');
    const tecnicos = usuarios.filter(u => u.rol === 'TECNICO');
    const usuariosNorm = usuarios.filter(u => u.rol === 'USUARIO');

    const ahora = new Date();

    const incidencias = [
      { titulo: 'Falla en servidor de producción', descripcion: 'El servidor web no responde desde las 8am.', categoria: 'Infraestructura', prioridad: 'CRITICA', estatus: 'EN_PROCESO', usuario_id: usuariosNorm[0].id, tecnico_id: tecnicos[0].id, activo: true, fecha_creacion: ahora, created_at: ahora, updated_at: ahora },
      { titulo: 'Error al exportar reportes PDF', descripcion: 'El módulo de reportes lanza excepción al exportar.', categoria: 'Software', prioridad: 'ALTA', estatus: 'ABIERTA', usuario_id: usuariosNorm[0].id, tecnico_id: null, activo: true, fecha_creacion: ahora, created_at: ahora, updated_at: ahora },
      { titulo: 'Impresora de recepción sin toner', descripcion: 'La impresora del área de recepción quedó sin toner.', categoria: 'Hardware', prioridad: 'BAJA', estatus: 'RESUELTA', usuario_id: usuariosNorm[1].id, tecnico_id: tecnicos[1].id, activo: true, fecha_creacion: ahora, fecha_cierre: ahora, created_at: ahora, updated_at: ahora },
      { titulo: 'VPN no conecta desde home office', descripcion: 'Varios usuarios reportan que la VPN corporativa no conecta.', categoria: 'Redes', prioridad: 'ALTA', estatus: 'EN_ESPERA', usuario_id: usuariosNorm[1].id, tecnico_id: tecnicos[0].id, activo: true, fecha_creacion: ahora, created_at: ahora, updated_at: ahora },
      { titulo: 'Actualización de licencias Office', descripcion: 'Las licencias de Office expiran la próxima semana.', categoria: 'Software', prioridad: 'MEDIA', estatus: 'ABIERTA', usuario_id: usuariosNorm[0].id, tecnico_id: null, activo: true, fecha_creacion: ahora, created_at: ahora, updated_at: ahora },
    ];

    await queryInterface.bulkInsert('incidencias', incidencias, {});
  },
  async down(queryInterface) {
    await queryInterface.bulkDelete('incidencias', null, {});
  },
};
