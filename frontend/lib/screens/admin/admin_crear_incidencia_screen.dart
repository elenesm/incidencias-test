import 'package:flutter/material.dart';
import '../../services/incidencia_service.dart';
import '../../models/incidencia_model.dart';

class AdminCrearIncidenciaScreen extends StatefulWidget {
  const AdminCrearIncidenciaScreen({super.key});
  @override
  State<AdminCrearIncidenciaScreen> createState() => _AdminCrearState();
}

class _AdminCrearState extends State<AdminCrearIncidenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = IncidenciaService();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _catCtrl = TextEditingController();

  List<UsuarioRef> _usuarios = [];
  List<UsuarioRef> _tecnicos = [];
  UsuarioRef? _usuarioSel;
  UsuarioRef? _tecnicoSel;
  String _prioridad = 'MEDIA';
  bool _loading = true;
  bool _saving = false;

  final List<String> _prioridades = ['BAJA', 'MEDIA', 'ALTA', 'CRITICA'];

  @override
  void initState() {
    super.initState();
    _cargarOpciones();
  }

  Future<void> _cargarOpciones() async {
    try {
      final usuarios = await _service.getUsuarios();
      final tecnicos = await _service.getTecnicos();
      setState(() {
        _usuarios = usuarios;
        _tecnicos = tecnicos;
        if (_usuarios.isNotEmpty) _usuarioSel = _usuarios.first;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _crear() async {
    if (!_formKey.currentState!.validate()) return;
    if (_usuarioSel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona el usuario que reporta.'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _saving = true);
    try {
      await _service.crearIncidenciaAdmin({
        'titulo': _tituloCtrl.text.trim(),
        'descripcion': _descCtrl.text.trim(),
        'categoria': _catCtrl.text.trim().isNotEmpty ? _catCtrl.text.trim() : null,
        'prioridad': _prioridad,
        'usuario_id': _usuarioSel!.id,
        if (_tecnicoSel != null) 'tecnico_id': _tecnicoSel!.id,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incidencia creada.'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Incidencia')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                // Título
                TextFormField(
                  controller: _tituloCtrl,
                  decoration: const InputDecoration(labelText: 'Título *', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido.' : null,
                ),
                const SizedBox(height: 12),

                // Descripción
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripción *',
                    hintText: 'Describe el problema, dónde ocurre, pasos para reproducirlo...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido.' : null,
                ),
                const SizedBox(height: 12),

                // Categoría
                TextFormField(
                  controller: _catCtrl,
                  decoration: const InputDecoration(labelText: 'Categoría (opcional)', hintText: 'Ej: Infraestructura, Software, Redes...', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),

                // Prioridad
                DropdownButtonFormField<String>(
                  value: _prioridad,
                  decoration: const InputDecoration(labelText: 'Prioridad', border: OutlineInputBorder()),
                  items: _prioridades.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setState(() => _prioridad = v!),
                ),
                const SizedBox(height: 12),

                // Usuario que reporta
                DropdownButtonFormField<UsuarioRef>(
                  value: _usuarioSel,
                  decoration: const InputDecoration(labelText: 'Reportado por *', border: OutlineInputBorder()),
                  items: _usuarios.map((u) => DropdownMenuItem(value: u, child: Text('${u.nombre} — ${u.email ?? ''}'))).toList(),
                  onChanged: (v) => setState(() => _usuarioSel = v),
                ),
                const SizedBox(height: 12),

                // Asignar técnico (opcional)
                DropdownButtonFormField<UsuarioRef>(
                  value: _tecnicoSel,
                  decoration: const InputDecoration(labelText: 'Asignar técnico (opcional)', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem<UsuarioRef>(value: null, child: Text('Sin asignar')),
                    ..._tecnicos.map((t) => DropdownMenuItem(value: t, child: Text('${t.nombre} — ${t.email ?? ''}')))
                  ],
                  onChanged: (v) => setState(() => _tecnicoSel = v),
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: _saving ? null : _crear,
                  icon: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check),
                  label: const Text('Crear incidencia'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ]),
            ),
    );
  }
}
