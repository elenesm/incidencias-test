import 'package:flutter/material.dart';
import '../../services/incidencia_service.dart';
import '../../models/incidencia_model.dart';
import '../../widgets/estatus_chip.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/chat_bubble.dart';

class AdminDetalleScreen extends StatefulWidget {
  final int incidenciaId;
  const AdminDetalleScreen({super.key, required this.incidenciaId});
  @override
  State<AdminDetalleScreen> createState() => _AdminDetalleState();
}

class _AdminDetalleState extends State<AdminDetalleScreen> {
  final _service = IncidenciaService();
  final _comentCtrl = TextEditingController();
  IncidenciaModel? _inc;
  List<UsuarioRef> _tecnicos = [];
  UsuarioRef? _tecnicoSeleccionado;
  bool _loading = true;
  bool _saving = false;
  bool _sendingChat = false;
  String? _nuevoEstatus;
  final List<String> _estatuses = ['ABIERTA','EN_PROCESO','EN_REVISION','EN_DESARROLLO','EN_ESPERA','RESUELTA','CERRADA'];

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final inc     = await _service.getDetalleAdmin(widget.incidenciaId);
      final tecnicos = await _service.getTecnicos();
      setState(() {
        _inc = inc;
        _nuevoEstatus = inc.estatus;
        _tecnicos = tecnicos;
        _tecnicoSeleccionado = inc.tecnicoId != null
            ? tecnicos.where((t) => t.id == inc.tecnicoId).firstOrNull
            : null;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _actualizarEstatus() async {
    if (_nuevoEstatus == null) return;
    setState(() => _saving = true);
    try {
      await _service.actualizarAdmin(widget.incidenciaId, {'estatus': _nuevoEstatus});
      _cargar();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estatus actualizado.'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _enviarComentario() async {
    if (_comentCtrl.text.trim().isEmpty) return;
    setState(() => _sendingChat = true);
    try {
      await _service.agregarComentarioAdmin(widget.incidenciaId, _comentCtrl.text.trim());
      _comentCtrl.clear();
      _cargar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _sendingChat = false);
    }
  }

  Future<void> _inactivar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Inactivar incidencia?'),
        content: const Text('Se ocultará de la vista operativa (soft delete). ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Inactivar')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _service.inactivar(widget.incidenciaId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incidencia inactivada.'), backgroundColor: Colors.orange));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle Supervisor'),
        actions: [IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Inactivar', onPressed: _inactivar, color: Colors.red)],
      ),
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
      // Info
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(inc.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [EstatusChip(inc.estatus), const SizedBox(width: 8), PrioridadChip(inc.prioridad)]),
        if (inc.categoria != null) ...[const SizedBox(height: 6), Text('Categoría: ${inc.categoria}', style: const TextStyle(color: Colors.grey))],
        const Divider(height: 20),
        Text(inc.descripcion),
        if (inc.usuario != null) ...[const Divider(height: 16), Text('Reportado por: ${inc.usuario!.nombre}')],
        if (inc.tecnico != null)
          Text('Técnico: ${inc.tecnico!.nombre}')
        else
          const Text('Sin técnico asignado.', style: TextStyle(color: Colors.grey)),
      ]))),

      const SizedBox(height: 12),

      // Asignar técnico
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Asignar técnico', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<UsuarioRef>(
          value: _tecnicoSeleccionado,
          decoration: const InputDecoration(labelText: 'Seleccionar técnico', border: OutlineInputBorder()),
          items: _tecnicos.map((t) => DropdownMenuItem(value: t, child: Text('${t.nombre} — ${t.email ?? ''}'))).toList(),
          onChanged: (v) => setState(() => _tecnicoSeleccionado = v),
        ),
        const SizedBox(height: 8),
        LoadingButton(loading: _saving, label: 'Asignar', onPressed: _asignar),
      ]))),

      const SizedBox(height: 12),

      // Cambiar estatus
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Cambiar estatus', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _nuevoEstatus,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: _estatuses.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _nuevoEstatus = v),
        ),
        const SizedBox(height: 8),
        LoadingButton(loading: _saving, label: 'Guardar estatus', onPressed: _actualizarEstatus),
      ]))),

      const SizedBox(height: 16),

      // Chat
      const Text('Conversación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      if (inc.logs == null || inc.logs!.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: Text('Sin mensajes aún.', style: TextStyle(color: Colors.grey))),
        )
      else
        ...inc.logs!.map((log) => ChatBubble(log: log, rolActual: 'SUPERVISOR')),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: TextField(
            controller: _comentCtrl,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Escribe una nota...',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: Colors.orange,
          child: _sendingChat
              ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: _enviarComentario),
        ),
      ]),
    ]);
  }
}
