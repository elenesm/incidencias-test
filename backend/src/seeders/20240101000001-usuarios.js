'use strict';
const bcrypt = require('bcryptjs');

module.exports = {
  async up(queryInterface) {
    const hash = (pwd) => bcrypt.hashSync(pwd, 10);
    await queryInterface.bulkInsert('usuarios', [
      { nombre: 'Admin Supervisor', email: 'supervisor@test.com', password_hash: hash('Admin123!'), rol: 'SUPERVISOR', created_at: new Date(), updated_at: new Date() },
      { nombre: 'Carlos Técnico', email: 'tecnico1@test.com', password_hash: hash('Tecnico123!'), rol: 'TECNICO', created_at: new Date(), updated_at: new Date() },
      { nombre: 'María Técnico', email: 'tecnico2@test.com', password_hash: hash('Tecnico123!'), rol: 'TECNICO', created_at: new Date(), updated_at: new Date() },
      { nombre: 'Juan Usuario', email: 'usuario1@test.com', password_hash: hash('Usuario123!'), rol: 'USUARIO', created_at: new Date(), updated_at: new Date() },
      { nombre: 'Ana Usuario', email: 'usuario2@test.com', password_hash: hash('Usuario123!'), rol: 'USUARIO', created_at: new Date(), updated_at: new Date() },
    ], {});
  },
  async down(queryInterface) {
    await queryInterface.bulkDelete('usuarios', null, {});
  },
};
