import 'package:flutter/material.dart';
import '../../services/incidencia_service.dart';

class AdminReportesScreen extends StatefulWidget {
  const AdminReportesScreen({super.key});
  @override
  State<AdminReportesScreen> createState() => _AdminReportesState();
}

class _AdminReportesState extends State<AdminReportesScreen> {
  final _service = IncidenciaService();
  Map<String, dynamic>? _reportes;
  bool _loading = true;

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try { final data = await _service.getReportes(); setState(() => _reportes = data); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _reportes == null ? const Center(child: Text('Sin datos.')) : RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          _seccion('Por Estatus', _reportes!['porEstatus'] as List, 'estatus', 'total'),
          const SizedBox(height: 16),
          _seccion('Por Prioridad', _reportes!['porPrioridad'] as List, 'prioridad', 'total'),
          const SizedBox(height: 16),
          _seccionTecnico('Por Técnico', _reportes!['porTecnico'] as List),
        ]),
      ),
    );
  }

  Widget _seccion(String titulo, List items, String labelKey, String countKey) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const Divider(),
      if (items.isEmpty) const Text('Sin datos.', style: TextStyle(color: Colors.grey))
      else ...items.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(item[labelKey]?.toString() ?? 'N/A'), Chip(label: Text(item[countKey].toString()))]))),
    ])));
  }

  Widget _seccionTecnico(String titulo, List items) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const Divider(),
      if (items.isEmpty) const Text('Sin datos.', style: TextStyle(color: Colors.grey))
      else ...items.map((item) {
        final tecnico = item['tecnico'] as Map<String, dynamic>?;
        return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(tecnico?['nombre'] ?? 'Sin nombre'), Chip(label: Text(item['total'].toString()))]));
      }),
    ])));
  }
}
