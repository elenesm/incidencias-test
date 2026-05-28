import 'package:flutter/material.dart';
import '../../services/incidencia_service.dart';
import '../../models/incidencia_model.dart';
import '../../widgets/estatus_chip.dart';

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
          const Text('Bitácora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (inc.logs == null || inc.logs!.isEmpty)
            const Text('Sin registros en bitácora.', style: TextStyle(color: Colors.grey))
          else
            ...inc.logs!.map((log) => Card(
              color: Colors.blue.shade50,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person, size: 18), radius: 18),
                title: Text(log.mensaje),
                subtitle: Text(log.autor?.nombre ?? 'Sistema', style: const TextStyle(fontSize: 12)),
                trailing: log.estatusNuevo != null ? EstatusChip(log.estatusNuevo!) : null,
              ),
            )),
          const SizedBox(height: 16),
          const Text('Agregar comentario', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _comentCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Escribe tu comentario...',
              border: const OutlineInputBorder(),
              suffixIcon: _sending
                  ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(icon: const Icon(Icons.send), onPressed: _enviarComentario),
            ),
          ),
        ],
      ),
    );
  }
}
