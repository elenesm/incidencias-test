import 'package:flutter/material.dart';
import '../../services/incidencia_service.dart';
import '../../models/incidencia_model.dart';
import '../../widgets/estatus_chip.dart';
import '../../widgets/loading_button.dart';

class AdminDetalleScreen extends StatefulWidget {
  final int incidenciaId;
  const AdminDetalleScreen({super.key, required this.incidenciaId});
  @override
  State<AdminDetalleScreen> createState() => _AdminDetalleState();
}

class _AdminDetalleState extends State<AdminDetalleScreen> {
  final _service = IncidenciaService();
  IncidenciaModel? _inc;
  List<UsuarioRef> _tecnicos = [];
  UsuarioRef? _tecnicoSeleccionado;
  bool _loading = true;
  bool _saving = false;
  String? _nuevoEstatus;
  final List<String> _estatuses = ['ABIERTA', 'EN_PROCESO', 'EN_ESPERA', 'RESUELTA', 'CERRADA'];

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _service.getTodasIncidencias(),
        _service.getTecnicos(),
      ]);
      final lista = results[0] as List<IncidenciaModel>;
      final tecnicos = results[1] as List<UsuarioRef>;
      final inc = lista.firstWhere((i) => i.id == widget.incidenciaId);
      setState(() {
        _inc = inc;
        _nuevoEstatus = inc.estatus;
        _tecnicos = tecnicos;
        _tecnicoSeleccionado = inc.tecnicoId != null
            ? tecnicos.where((t) => t.id == inc.tecnicoId).firstOrNull
            : null;
      });
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _asignar() async {
    if (_tecnicoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un técnico.'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _saving = true);
    try {
      await _service.asignarTecnico(widget.incidenciaId, _tecnicoSeleccionado!.id);
      _cargar();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Técnico asignado.'), backgroundColor: Colors.green));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  Future<void> _actualizarEstatus() async {
    if (_nuevoEstatus == null) return;
    setState(() => _saving = true);
    try { await _service.actualizarAdmin(widget.incidenciaId, {'estatus': _nuevoEstatus}); _cargar(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estatus actualizado.'), backgroundColor: Colors.green)); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  Future<void> _inactivar() async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('¿Inactivar incidencia?'), content: const Text('Esta acción ocultará la incidencia (soft delete). ¿Continuar?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Inactivar'))]));
    if (confirm != true) return;
    try { await _service.inactivar(widget.incidenciaId); if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incidencia inactivada.'), backgroundColor: Colors.orange)); } }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Admin'), actions: [IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Inactivar', onPressed: _inactivar, color: Colors.red)]),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _inc == null ? const Center(child: Text('No encontrada.')) : ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_inc!.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [EstatusChip(_inc!.estatus), const SizedBox(width: 8), PrioridadChip(_inc!.prioridad)]),
          const Divider(height: 20),
          Text(_inc!.descripcion),
          if (_inc!.usuario != null) ...[const Divider(), Text('Creado por: ${_inc!.usuario!.nombre}')],
          if (_inc!.tecnico != null) Text('Técnico: ${_inc!.tecnico!.nombre}') else const Text('Sin técnico asignado.', style: TextStyle(color: Colors.grey)),
        ]))),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Asignar técnico', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<UsuarioRef>(
            value: _tecnicoSeleccionado,
            decoration: const InputDecoration(labelText: 'Seleccionar técnico', border: OutlineInputBorder()),
            items: _tecnicos.map((t) => DropdownMenuItem(
              value: t,
              child: Text('${t.nombre} — ${t.email ?? ''}'),
            )).toList(),
            onChanged: (v) => setState(() => _tecnicoSeleccionado = v),
          ),
          const SizedBox(height: 8),
          LoadingButton(loading: _saving, label: 'Asignar', onPressed: _asignar),
        ]))),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Cambiar estatus', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(value: _nuevoEstatus, decoration: const InputDecoration(border: OutlineInputBorder()), items: _estatuses.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _nuevoEstatus = v)),
          const SizedBox(height: 8),
          LoadingButton(loading: _saving, label: 'Guardar estatus', onPressed: _actualizarEstatus),
        ]))),
      ]),
    );
  }
}
