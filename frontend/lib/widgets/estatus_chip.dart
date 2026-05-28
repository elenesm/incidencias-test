import 'package:flutter/material.dart';
import '../utils/colors.dart';

class EstatusChip extends StatelessWidget {
  final String estatus;
  const EstatusChip(this.estatus, {super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(estatus, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: estatusColor(estatus),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class PrioridadChip extends StatelessWidget {
  final String? prioridad;
  const PrioridadChip(this.prioridad, {super.key});

  @override
  Widget build(BuildContext context) {
    if (prioridad == null) return const SizedBox.shrink();
    return Chip(
      label: Text(prioridad!, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: prioridadColor(prioridad),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
