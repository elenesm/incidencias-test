import 'package:flutter/material.dart';
import '../../services/incidencia_service.dart';
import '../../widgets/loading_button.dart';

class NuevaIncidenciaScreen extends StatefulWidget {
  const NuevaIncidenciaScreen({super.key});
  @override
  State<NuevaIncidenciaScreen> createState() => _NuevaIncidenciaScreenState();
}

class _NuevaIncidenciaScreenState extends State<NuevaIncidenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _catCtrl = TextEditingController();
  final _service = IncidenciaService();
  bool _loading = false;
  String? _prioridad;

  final List<String> _prioridades = ['BAJA', 'MEDIA', 'ALTA', 'CRITICA'];

  @override
  void dispose() { _tituloCtrl.dispose(); _descCtrl.dispose(); _catCtrl.dispose(); super.dispose(); }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _service.crearIncidencia({
        'titulo': _tituloCtrl.text.trim(),
        'descripcion': _descCtrl.text.trim(),
        if (_catCtrl.text.isNotEmpty) 'categoria': _catCtrl.text.trim(),
        if (_prioridad != null) 'prioridad': _prioridad,
      });
      if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incidencia creada exitosamente.'), backgroundColor: Colors.green)); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Incidencia')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _tituloCtrl, decoration: const InputDecoration(labelText: 'Título *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requerido.' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _descCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Descripción *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requerido.' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _catCtrl, decoration: const InputDecoration(labelText: 'Categoría (opcional)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _prioridad,
                decoration: const InputDecoration(labelText: 'Prioridad', border: OutlineInputBorder()),
                items: _prioridades.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _prioridad = v),
              ),
              const SizedBox(height: 24),
              LoadingButton(loading: _loading, label: 'Crear Incidencia', onPressed: _guardar),
            ],
          ),
        ),
      ),
    );
  }
}
