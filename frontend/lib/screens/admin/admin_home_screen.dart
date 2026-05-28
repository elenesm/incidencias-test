import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/incidencia_service.dart';
import '../../models/incidencia_model.dart';
import '../../config/routes.dart';
import '../../widgets/incidencia_card.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _service = IncidenciaService();
  final _auth = AuthService();
  List<IncidenciaModel> _incidencias = [];
  bool _loading = true;
  String? _filtroEstatus;
  String? _filtroPrioridad;
  final List<String> _estatuses = ['TODAS', 'ABIERTA', 'EN_PROCESO', 'EN_ESPERA', 'RESUELTA', 'CERRADA'];
  final List<String> _prioridades = ['TODAS', 'BAJA', 'MEDIA', 'ALTA', 'CRITICA'];

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final filtros = <String, String>{};
      if (_filtroEstatus != null && _filtroEstatus != 'TODAS') filtros['estatus'] = _filtroEstatus!;
      if (_filtroPrioridad != null && _filtroPrioridad != 'TODAS') filtros['prioridad'] = _filtroPrioridad!;
      final data = await _service.getTodasIncidencias(filtros: filtros);
      setState(() => _incidencias = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tablero Supervisor'),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), tooltip: 'Reportes', onPressed: () => Navigator.pushNamed(context, AppRoutes.adminReportes)),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async { await _auth.logout(); if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false); }),
        ],
      ),
      body: Column(children: [
        ExpansionTile(
          title: const Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold)),
          children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Column(children: [
              DropdownButtonFormField<String>(value: _filtroEstatus ?? 'TODAS', decoration: const InputDecoration(labelText: 'Estatus', border: OutlineInputBorder()), items: _estatuses.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) { setState(() => _filtroEstatus = v); _cargar(); }),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(value: _filtroPrioridad ?? 'TODAS', decoration: const InputDecoration(labelText: 'Prioridad', border: OutlineInputBorder()), items: _prioridades.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) { setState(() => _filtroPrioridad = v); _cargar(); }),
            ])),
          ],
        ),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Row(children: [Text('${_incidencias.length} incidencias', style: const TextStyle(color: Colors.grey))])),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _incidencias.isEmpty ? const Center(child: Text('Sin incidencias.')) : RefreshIndicator(onRefresh: _cargar, child: ListView.builder(itemCount: _incidencias.length, itemBuilder: (ctx, i) => IncidenciaCard(incidencia: _incidencias[i], onTap: () async { await Navigator.pushNamed(ctx, AppRoutes.adminDetalleIncidencia, arguments: _incidencias[i].id); _cargar(); })))),
      ]),
    );
  }
}
