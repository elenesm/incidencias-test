import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1565C0);
  static const secondary = Color(0xFF0288D1);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF57F17);
  static const danger = Color(0xFFC62828);
  static const surface = Color(0xFFF5F5F5);
}

Color estatusColor(String estatus) {
  switch (estatus) {
    case 'ABIERTA':      return Colors.blue;
    case 'EN_PROCESO':   return Colors.orange;
    case 'EN_REVISION':  return Colors.indigo;
    case 'EN_DESARROLLO':return const Color(0xFF00897B); // teal
    case 'EN_ESPERA':    return Colors.purple;
    case 'RESUELTA':     return Colors.green;
    case 'CERRADA':      return Colors.grey;
    default:             return Colors.blueGrey;
  }
}

Color prioridadColor(String? prioridad) {
  switch (prioridad) {
    case 'CRITICA': return Colors.red;
    case 'ALTA': return Colors.deepOrange;
    case 'MEDIA': return Colors.orange;
    case 'BAJA': return Colors.green;
    default: return Colors.grey;
  }
}
