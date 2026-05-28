class UsuarioModel {
  final int id;
  final String nombre;
  final String email;
  final String rol;

  UsuarioModel({required this.id, required this.nombre, required this.email, required this.rol});

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
        id: json['id'],
        nombre: json['nombre'],
        email: json['email'],
        rol: json['rol'],
      );
}
