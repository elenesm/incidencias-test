import 'package:flutter/material.dart';
import '../models/incidencia_model.dart';
import '../utils/colors.dart';

class ChatBubble extends StatelessWidget {
  final LogModel log;
  final String? rolActual; // rol del usuario autenticado

  const ChatBubble({super.key, required this.log, this.rolActual});

  String get _rol => log.autor?.rol ?? 'SISTEMA';

  bool get _esMio => log.autor?.rol == rolActual;

  Color get _bubbleColor {
    switch (_rol) {
      case 'USUARIO':     return const Color(0xFFE3F2FD);
      case 'TECNICO':     return const Color(0xFFE8F5E9);
      case 'SUPERVISOR':  return const Color(0xFFFFF3E0);
      default:            return const Color(0xFFF5F5F5);
    }
  }

  Color get _accentColor {
    switch (_rol) {
      case 'USUARIO':     return Colors.blue;
      case 'TECNICO':     return Colors.green;
      case 'SUPERVISOR':  return Colors.orange;
      default:            return Colors.grey;
    }
  }

  IconData get _roleIcon {
    switch (_rol) {
      case 'TECNICO':    return Icons.build;
      case 'SUPERVISOR': return Icons.admin_panel_settings;
      default:           return Icons.person;
    }
  }

  String get _timestamp {
    if (log.createdAt == null) return '';
    try {
      final dt = DateTime.parse(log.createdAt!).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      final d = '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}';
      return '$d  $h:$m';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    final isSistema = log.autor == null;

    if (isSistema) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
            child: Text(log.mensaje, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 4, bottom: 4,
        left: _esMio ? 40 : 0,
        right: _esMio ? 0 : 40,
      ),
      child: Column(
        crossAxisAlignment: _esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Nombre + rol
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_esMio) ...[
                  Icon(_roleIcon, size: 12, color: _accentColor),
                  const SizedBox(width: 4),
                ],
                Text(
                  log.autor?.nombre ?? '',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _accentColor),
                ),
                if (_esMio) ...[
                  const SizedBox(width: 4),
                  Icon(_roleIcon, size: 12, color: _accentColor),
                ],
              ],
            ),
          ),
          const SizedBox(height: 2),
          // Burbuja
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(_esMio ? 16 : 4),
                bottomRight: Radius.circular(_esMio ? 4 : 16),
              ),
              border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.mensaje, style: const TextStyle(fontSize: 14)),
                if (log.estatusNuevo != null) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.update, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: estatusColor(log.estatusNuevo!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(log.estatusNuevo!, style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ]),
                ],
                const SizedBox(height: 4),
                Text(_timestamp, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
