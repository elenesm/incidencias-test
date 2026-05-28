import 'package:flutter/material.dart';
import '../models/incidencia_model.dart';
import 'estatus_chip.dart';

class IncidenciaCard extends StatelessWidget {
  final IncidenciaModel incidencia;
  final VoidCallback onTap;

  const IncidenciaCard({super.key, required this.incidencia, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(incidencia.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(incidencia.categoria ?? 'Sin categoría', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Row(children: [EstatusChip(incidencia.estatus), const SizedBox(width: 8), PrioridadChip(incidencia.prioridad)]),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
      ),
    );
  }
}
