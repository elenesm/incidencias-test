'use strict';
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { Usuario } = require('../models');

const logout = (_req, res) => {
  // El cliente elimina el token en su almacenamiento local.
  // Aquí se puede agregar un blacklist de tokens si se requiere invalidación server-side.
  return res.json({ ok: true, message: 'Sesión cerrada correctamente.' });
};

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const usuario = await Usuario.findOne({ where: { email } });
    if (!usuario) {
      return res.status(401).json({ ok: false, message: 'Credenciales inválidas.' });
    }

    const passwordValida = await bcrypt.compare(password, usuario.password_hash);
    if (!passwordValida) {
      return res.status(401).json({ ok: false, message: 'Credenciales inválidas.' });
    }

    const payload = { id: usuario.id, email: usuario.email, rol: usuario.rol, nombre: usuario.nombre };
    const token = jwt.sign(payload, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || '24h',
    });

    return res.json({
      ok: true,
      token,
      usuario: { id: usuario.id, nombre: usuario.nombre, email: usuario.email, rol: usuario.rol },
    });
  } catch (err) {
    next(err);
  }
};

module.exports = { login, logout };
