import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/incidencia_service.dart';
import '../../models/incidencia_model.dart';
import '../../config/routes.dart';
import '../../widgets/incidencia_card.dart';

class TecnicoHomeScreen extends StatefulWidget {
  const TecnicoHomeScreen({super.key});
  @override
  State<TecnicoHomeScreen> createState() => _TecnicoHomeScreenState();
}

class _TecnicoHomeScreenState extends State<TecnicoHomeScreen> {
  final _service = IncidenciaService();
  final _auth = AuthService();
  List<IncidenciaModel> _incidencias = [];
  bool _loading = true;
  String? _error;
  String? _filtro;
  final List<String> _estatuses = ['TODAS', 'EN_PROCESO', 'EN_REVISION', 'EN_DESARROLLO', 'EN_ESPERA', 'RESUELTA'];

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getMisAsignadas(estatus: _filtro == 'TODAS' ? null : _filtro);
      setState(() => _incidencias = data);
    } catch (e) { setState(() => _error = e.toString()); }
    finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Asignaciones'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () async { await _auth.logout(); if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false); })],
      ),
      body: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: _estatuses.map((e) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(e), selected: (_filtro ?? 'TODAS') == e, onSelected: (_) { setState(() => _filtro = e); _cargar(); }))).toList()),
        ),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? Center(child: Text(_error!)) : _incidencias.isEmpty ? const Center(child: Text('Sin incidencias asignadas.')) : RefreshIndicator(onRefresh: _cargar, child: ListView.builder(itemCount: _incidencias.length, itemBuilder: (ctx, i) => IncidenciaCard(incidencia: _incidencias[i], onTap: () async { await Navigator.pushNamed(ctx, AppRoutes.tecnicoDetalleIncidencia, arguments: _incidencias[i].id); _cargar(); })))),
      ]),
    );
  }
}
