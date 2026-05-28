import 'dart:convert';
import 'api_service.dart';
import '../models/incidencia_model.dart';

class IncidenciaService {
  final ApiService _api = ApiService();

  // ── USUARIO ──────────────────────────────────────────
  Future<List<IncidenciaModel>> getMisIncidencias({String? estatus}) async {
    final path = '/usuario/incidencias${estatus != null ? '?estatus=$estatus' : ''}';
    final res = await _api.get(path);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['incidencias'] as List).map((e) => IncidenciaModel.fromJson(e)).toList();
    }
    throw Exception(jsonDecode(res.body)['message'] ?? 'Error al cargar incidencias.');
  }

  Future<IncidenciaModel> getMiIncidencia(int id) async {
    final res = await _api.get('/usuario/incidencias/$id');
    if (res.statusCode == 200) return IncidenciaModel.fromJson(jsonDecode(res.body)['incidencia']);
    throw Exception(jsonDecode(res.body)['message'] ?? 'Error.');
  }

  Future<void> crearIncidencia(Map<String, dynamic> datos) async {
    final res = await _api.post('/usuario/incidencias', datos);
    if (res.statusCode != 201) throw Exception(jsonDecode(res.body)['message'] ?? 'Error al crear.');
  }

  Future<void> agregarComentarioUsuario(int id, String mensaje) async {
    final res = await _api.post('/usuario/incidencias/$id/comentarios', {'mensaje': mensaje});
    if (res.statusCode != 201) throw Exception(jsonDecode(res.body)['message'] ?? 'Error.');
  }

  // ── TÉCNICO ──────────────────────────────────────────
  Future<List<IncidenciaModel>> getMisAsignadas({String? estatus}) async {
    final path = '/tecnico/incidencias${estatus != null ? '?estatus=$estatus' : ''}';
    final res = await _api.get(path);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['incidencias'] as List).map((e) => IncidenciaModel.fromJson(e)).toList();
    }
    throw Exception(jsonDecode(res.body)['message'] ?? 'Error.');
  }

  Future<IncidenciaModel> getAsignada(int id) async {
    final res = await _api.get('/tecnico/incidencias/$id');
    if (res.statusCode == 200) return IncidenciaModel.fromJson(jsonDecode(res.body)['incidencia']);
    throw Exception(jsonDecode(res.body)['message'] ?? 'Error.');
  }

  Future<void> actualizarEstatus(int id, {String? estatus, String? comentario}) async {
    final body = <String, dynamic>{};
    if (estatus != null) body['estatus'] = estatus;
    if (comentario != null) body['comentario'] = comentario;
    final res = await _api.patch('/tecnico/incidencias/$id', body);
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['message'] ?? 'Error.');
  }

  Future<void> agregarComentarioTecnico(int id, String mensaje) async {
    final res = await _api.post('/tecnico/incidencias/$id/comentarios', {'mensaje': mensaje});
    if (res.statusCode != 201) throw Exception(jsonDecode(res.body)['message'] ?? 'Error.');
  }

  // ── ADMIN ─────────────────────────────────────────────
  Future<List<IncidenciaModel>> getTodasIncidencias({Map<String, String>? filtros}) async {
    String query = '';
    if (filtros != null && filtros.isNotEmpty) {
      query = '?' + filtros.entries.map((e) => '${e.key}=${e.value}').join('&');
    }
    final res = await _api.get('/admin/incidencias$query');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['incidencias'] as List).map((e) => IncidenciaModel.fromJson(e)).toList();
    }
    throw Exception(jsonDecode(res.body)['message'] ?? 'Error.');
  }

  Future<void> asignarTecnico(int incidenciaId, int tecnicoId) async {
    final res = await _api.post('/admin/incidencias/$incidenciaId/asignar', {'tecnico_id': tecnicoId});
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['message'] ?? 'Error.');
  }

  Future<void> actualizarAdmin(int id, Map<String, dynamic> datos) async {
    final res = await _api.patch('/admin/incidencias/$id', datos);
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['message'] ?? 'Error.');
  }

  Future<List<UsuarioRef>> getTecnicos() async {
    final res = await _api.get('/admin/tecnicos');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['tecnicos'] as List).map((e) => UsuarioRef.fromJson(e)).toList();
    }
    throw Exception(jsonDecode(res.body)['message'] ?? 'Error al cargar técnicos.');
  }

  Future<void> inactivar(int id) async {
    final res = await _api.delete('/admin/incidencias/$id');
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['message'] ?? 'Error.');
  }

  Future<Map<String, dynamic>> getReportes({String? desde, String? hasta}) async {
    String query = '';
    if (desde != null) query += '?desde=$desde';
    if (hasta != null) query += '${query.isEmpty ? '?' : '&'}hasta=$hasta';
    final res = await _api.get('/admin/reportes$query');
    if (res.statusCode == 200) return jsonDecode(res.body)['reportes'];
    throw Exception(jsonDecode(res.body)['message'] ?? 'Error.');
  }
}
