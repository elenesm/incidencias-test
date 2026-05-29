import 'package:flutter/material.dart';
import '../../services/incidencia_service.dart';
import '../../models/incidencia_model.dart';
import '../../widgets/estatus_chip.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/chat_bubble.dart';

class TecnicoDetalleScreen extends StatefulWidget {
  final int incidenciaId;
  const TecnicoDetalleScreen({super.key, required this.incidenciaId});
  @override
  State<TecnicoDetalleScreen> createState() => _TecnicoDetalleState();
}

class _TecnicoDetalleState extends State<TecnicoDetalleScreen> {
  final _service = IncidenciaService();
  final _comentCtrl = TextEditingController();
  IncidenciaModel? _inc;
  bool _loading = true;
  bool _saving = false;
  String? _nuevoEstatus;
  final List<String> _estatuses = ['EN_PROCESO', 'EN_REVISION', 'EN_DESARROLLO', 'EN_ESPERA', 'RESUELTA'];

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final d = await _service.getAsignada(widget.incidenciaId);
      setState(() {
        _inc = d;
        _nuevoEstatus = _estatuses.contains(d.estatus) ? d.estatus : _estatuses.first;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _actualizar() async {
    setState(() => _saving = true);
    try {
      await _service.actualizarEstatus(
        widget.incidenciaId,
        estatus: _nuevoEstatus,
        comentario: _comentCtrl.text.trim().isNotEmpty ? _comentCtrl.text.trim() : null,
      );
      _comentCtrl.clear();
      _cargar();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actualizado correctamente.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Técnico')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _inc == null
              ? const Center(child: Text('No encontrada.'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final inc = _inc!;
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Info de la incidencia
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(inc.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [EstatusChip(inc.estatus), const SizedBox(width: 8), PrioridadChip(inc.prioridad)]),
        if (inc.categoria != null) ...[const SizedBox(height: 6), Text('Categoría: ${inc.categoria}', style: const TextStyle(color: Colors.grey))],
        const Divider(height: 20),
        Text(inc.descripcion),
        if (inc.usuario != null) ...[const Divider(height: 16), Text('Reportado por: ${inc.usuario!.nombre}')],
      ]))),

      const SizedBox(height: 16),

      // Panel de actualización
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Actualizar estatus', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _nuevoEstatus,
          decoration: const InputDecoration(labelText: 'Nuevo estatus', border: OutlineInputBorder()),
          items: _estatuses.map((e) => DropdownMenuItem(
            value: e,
            child: Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: _estatusColor(e))),
              const SizedBox(width: 8),
              Text(e),
            ]),
          )).toList(),
          onChanged: (v) => setState(() => _nuevoEstatus = v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _comentCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Nota técnica (opcional)',
            hintText: 'Describe el avance, donde está el error, pasos realizados...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        LoadingButton(loading: _saving, label: 'Guardar cambios', onPressed: _actualizar),
      ]))),

      const SizedBox(height: 16),

      // Chat / Conversación
      const Text('Conversación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      if (inc.logs == null || inc.logs!.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: Text('Sin mensajes aún.', style: TextStyle(color: Colors.grey))),
        )
      else
        ...inc.logs!.map((log) => ChatBubble(log: log, rolActual: 'TECNICO')),
    ]);
  }

  Color _estatusColor(String e) {
    const m = {
      'EN_PROCESO': Colors.orange, 'EN_REVISION': Colors.indigo,
      'EN_DESARROLLO': Color(0xFF00897B), 'EN_ESPERA': Colors.purple, 'RESUELTA': Colors.green,
    };
    return m[e] ?? Colors.blueGrey;
  }
}
