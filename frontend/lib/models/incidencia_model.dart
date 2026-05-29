class IncidenciaModel {
  final int id;
  final String titulo;
  final String descripcion;
  final String? categoria;
  final String? prioridad;
  final String estatus;
  final int usuarioId;
  final int? tecnicoId;
  final bool activo;
  final String? fechaCreacion;
  final String? fechaCierre;
  final UsuarioRef? usuario;
  final UsuarioRef? tecnico;
  final List<LogModel>? logs;

  IncidenciaModel({
    required this.id, required this.titulo, required this.descripcion,
    this.categoria, this.prioridad, required this.estatus,
    required this.usuarioId, this.tecnicoId, required this.activo,
    this.fechaCreacion, this.fechaCierre, this.usuario, this.tecnico, this.logs,
  });

  factory IncidenciaModel.fromJson(Map<String, dynamic> json) => IncidenciaModel(
        id: json['id'],
        titulo: json['titulo'],
        descripcion: json['descripcion'],
        categoria: json['categoria'],
        prioridad: json['prioridad'],
        estatus: json['estatus'],
        usuarioId: json['usuario_id'],
        tecnicoId: json['tecnico_id'],
        activo: json['activo'] ?? true,
        fechaCreacion: json['fecha_creacion'],
        fechaCierre: json['fecha_cierre'],
        usuario: json['usuario'] != null ? UsuarioRef.fromJson(json['usuario']) : null,
        tecnico: json['tecnico'] != null ? UsuarioRef.fromJson(json['tecnico']) : null,
        logs: json['logs'] != null
            ? (json['logs'] as List).map((l) => LogModel.fromJson(l)).toList()
            : null,
      );
}

class UsuarioRef {
  final int id;
  final String nombre;
  final String? email;
  final String? rol;

  UsuarioRef({required this.id, required this.nombre, this.email, this.rol});
  factory UsuarioRef.fromJson(Map<String, dynamic> json) =>
      UsuarioRef(id: json['id'], nombre: json['nombre'], email: json['email'], rol: json['rol']);
}

class LogModel {
  final int id;
  final String mensaje;
  final String? estatusNuevo;
  final String? createdAt;
  final UsuarioRef? autor;

  LogModel({required this.id, required this.mensaje, this.estatusNuevo, this.createdAt, this.autor});
  factory LogModel.fromJson(Map<String, dynamic> json) => LogModel(
        id: json['id'],
        mensaje: json['mensaje'],
        estatusNuevo: json['estatus_nuevo'],
        createdAt: json['created_at'],
        autor: json['autor'] != null ? UsuarioRef.fromJson(json['autor']) : null,
      );
}
