import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../config/routes.dart';

class RouteGuard {
  static final AuthService _auth = AuthService();

  /// Verifica si el usuario puede acceder a la ruta según su rol.
  /// Si ENABLE_ROUTE_GUARDS es false, siempre permite (smoke tests).
  static Future<Widget?> check({
    required Widget destination,
    required List<String> rolesPermitidos,
    required BuildContext context,
  }) async {
    if (!ENABLE_ROUTE_GUARDS) return destination;

    final loggedIn = await _auth.isLoggedIn();
    if (!loggedIn) return null; // redirige a login

    final usuario = await _auth.getUsuario();
    if (usuario == null || !rolesPermitidos.contains(usuario.rol)) {
      return const _AccesoDenegadoScreen();
    }
    return destination;
  }
}

class _AccesoDenegadoScreen extends StatelessWidget {
  const _AccesoDenegadoScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso Denegado')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text('No tienes permiso para acceder a esta sección.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false),
              child: const Text('Ir al Login'),
            ),
          ],
        ),
      ),
    );
  }
}
