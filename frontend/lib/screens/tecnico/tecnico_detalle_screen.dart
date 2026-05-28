import 'package:flutter/material.dart';
import '../../services/incidencia_service.dart';
import '../../models/incidencia_model.dart';
import '../../widgets/estatus_chip.dart';
import '../../widgets/loading_button.dart';

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
  final List<String> _estatuses = ['EN_PROCESO', 'EN_ESPERA', 'RESUELTA'];

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try { final d = await _service.getAsignada(widget.incidenciaId); setState(() { _inc = d; _nuevoEstatus = d.estatus; }); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _actualizar() async {
    setState(() => _saving = true);
    try {
      await _service.actualizarEstatus(widget.incidenciaId, estatus: _nuevoEstatus, comentario: _comentCtrl.text.trim().isNotEmpty ? _comentCtrl.text.trim() : null);
      _comentCtrl.clear();
      _cargar();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Actualizado correctamente.'), backgroundColor: Colors.green));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Técnico')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _inc == null ? const Center(child: Text('No encontrada.')) : ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_inc!.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [EstatusChip(_inc!.estatus), const SizedBox(width: 8), PrioridadChip(_inc!.prioridad)]),
          const Divider(height: 20),
          Text(_inc!.descripcion),
          if (_inc!.usuario != null) ...[const Divider(height: 20), Text('Reportado por: ${_inc!.usuario!.nombre}')],
        ]))),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Actualizar estatus', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _estatuses.contains(_nuevoEstatus) ? _nuevoEstatus : _estatuses.first,
            decoration: const InputDecoration(labelText: 'Nuevo estatus', border: OutlineInputBorder()),
            items: _estatuses.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _nuevoEstatus = v),
          ),
          const SizedBox(height: 12),
          TextField(controller: _comentCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Comentario / nota técnica', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          LoadingButton(loading: _saving, label: 'Guardar cambios', onPressed: _actualizar),
        ]))),
        const SizedBox(height: 16),
        const Text('Bitácora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...(_inc!.logs ?? []).map((log) => Card(color: Colors.green.shade50, margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person, size: 18), radius: 18), title: Text(log.mensaje), subtitle: Text(log.autor?.nombre ?? 'Sistema'), trailing: log.estatusNuevo != null ? EstatusChip(log.estatusNuevo!) : null))),
      ]),
    );
  }
}
