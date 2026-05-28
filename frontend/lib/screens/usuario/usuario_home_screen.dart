import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/incidencia_service.dart';
import '../../models/incidencia_model.dart';
import '../../config/routes.dart';
import '../../widgets/incidencia_card.dart';

class UsuarioHomeScreen extends StatefulWidget {
  const UsuarioHomeScreen({super.key});
  @override
  State<UsuarioHomeScreen> createState() => _UsuarioHomeScreenState();
}

class _UsuarioHomeScreenState extends State<UsuarioHomeScreen> {
  final _service = IncidenciaService();
  final _auth = AuthService();
  List<IncidenciaModel> _incidencias = [];
  bool _loading = true;
  String? _error;
  String? _filtroEstatus;

  final List<String> _estatuses = ['TODAS', 'ABIERTA', 'EN_PROCESO', 'EN_ESPERA', 'RESUELTA', 'CERRADA'];

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getMisIncidencias(estatus: _filtroEstatus == 'TODAS' ? null : _filtroEstatus);
      setState(() { _incidencias = data; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Incidencias'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Cerrar sesión')],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.usuarioNuevaIncidencia);
          _cargar();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _estatuses.map((e) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(e),
                  selected: (_filtroEstatus ?? 'TODAS') == e,
                  onSelected: (_) { setState(() => _filtroEstatus = e); _cargar(); },
                ),
              )).toList(),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error, color: Colors.red, size: 48), const SizedBox(height: 8), Text(_error!), TextButton(onPressed: _cargar, child: const Text('Reintentar'))]));
    if (_incidencias.isEmpty) return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inbox, size: 64, color: Colors.grey), SizedBox(height: 8), Text('Sin incidencias')]));
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        itemCount: _incidencias.length,
        itemBuilder: (ctx, i) => IncidenciaCard(
          incidencia: _incidencias[i],
          onTap: () async {
            await Navigator.pushNamed(ctx, AppRoutes.usuarioDetalleIncidencia, arguments: _incidencias[i].id);
            _cargar();
          },
        ),
      ),
    );
  }
}
