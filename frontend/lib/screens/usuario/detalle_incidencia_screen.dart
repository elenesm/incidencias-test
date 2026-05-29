import 'package:flutter/material.dart';
import '../../services/incidencia_service.dart';
import '../../models/incidencia_model.dart';
import '../../widgets/estatus_chip.dart';
import '../../widgets/chat_bubble.dart';

class DetalleIncidenciaUsuarioScreen extends StatefulWidget {
  final int incidenciaId;
  const DetalleIncidenciaUsuarioScreen({super.key, required this.incidenciaId});
  @override
  State<DetalleIncidenciaUsuarioScreen> createState() => _DetalleState();
}

class _DetalleState extends State<DetalleIncidenciaUsuarioScreen> {
  final _service = IncidenciaService();
  final _comentCtrl = TextEditingController();
  IncidenciaModel? _incidencia;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getMiIncidencia(widget.incidenciaId);
      setState(() { _incidencia = data; });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _enviarComentario() async {
    if (_comentCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await _service.agregarComentarioUsuario(widget.incidenciaId, _comentCtrl.text.trim());
      _comentCtrl.clear();
      _cargar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Incidencia')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _incidencia == null
              ? const Center(child: Text('No encontrada.'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final inc = _incidencia!;
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(inc.titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [EstatusChip(inc.estatus), const SizedBox(width: 8), PrioridadChip(inc.prioridad)]),
              if (inc.categoria != null) ...[const SizedBox(height: 8), Text('Categoría: ${inc.categoria}', style: const TextStyle(color: Colors.grey))],
              const Divider(height: 24),
              Text(inc.descripcion),
              if (inc.tecnico != null) ...[const Divider(height: 24), Text('Técnico asignado: ${inc.tecnico!.nombre}', style: const TextStyle(fontWeight: FontWeight.w500))],
            ]),
          )),
          const SizedBox(height: 16),
          const Text('Conversación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (inc.logs == null || inc.logs!.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('Sin mensajes aún.', style: TextStyle(color: Colors.grey))),
            )
          else
            ...inc.logs!.map((log) => ChatBubble(log: log, rolActual: 'USUARIO')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _comentCtrl,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: _sending
                  ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: _enviarComentario),
            ),
          ]),
        ],
      ),
    );
  }
}
