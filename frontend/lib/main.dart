import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/app_config.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'models/usuario_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/usuario/usuario_home_screen.dart';
import 'screens/usuario/nueva_incidencia_screen.dart';
import 'screens/usuario/detalle_incidencia_screen.dart';
import 'screens/tecnico/tecnico_home_screen.dart';
import 'screens/tecnico/tecnico_detalle_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/admin_detalle_screen.dart';
import 'screens/admin/admin_reportes_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  ApiService.onUnauthorized = () {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  };
  runApp(const IncidenciasApp());
}

class IncidenciasApp extends StatelessWidget {
  const IncidenciasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Incidencias',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1565C0),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const _SplashRouter(),
      onGenerateRoute: _generateRoute,
    );
  }

  static Route<dynamic>? _generateRoute(RouteSettings settings) {
    final authService = AuthService();

    // Rutas públicas (sin guard)
    if (settings.name == AppRoutes.login) {
      return MaterialPageRoute(builder: (_) => const LoginScreen(), settings: settings);
    }

    // Rutas protegidas: se validan de forma síncrona mediante FutureBuilder
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => FutureBuilder<_RouteResult>(
        future: _resolveRoute(settings, authService),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          final result = snap.data!;
          if (result.redirect != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamedAndRemoveUntil(ctx, result.redirect!, (_) => false);
            });
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return result.widget!;
        },
      ),
    );
  }

  static Future<_RouteResult> _resolveRoute(RouteSettings settings, AuthService auth) async {
    // Si guards desactivados (smoke tests), renderiza sin validar
    if (!ENABLE_ROUTE_GUARDS) {
      return _RouteResult(widget: _buildScreen(settings));
    }

    final loggedIn = await auth.isLoggedIn();
    if (!loggedIn) return const _RouteResult(redirect: AppRoutes.login);

    final usuario = await auth.getUsuario();
    if (usuario == null) return const _RouteResult(redirect: AppRoutes.login);

    // Validar rol por ruta
    final rolRequerido = _rolParaRuta(settings.name ?? '');
    if (rolRequerido != null && usuario.rol != rolRequerido) {
      return _RouteResult(widget: _accesoNegado(usuario.rol));
    }

    return _RouteResult(widget: _buildScreen(settings));
  }

  static String? _rolParaRuta(String name) {
    if (name.startsWith('/usuario')) return 'USUARIO';
    if (name.startsWith('/tecnico')) return 'TECNICO';
    if (name.startsWith('/admin')) return 'SUPERVISOR';
    return null;
  }

  static Widget? _buildScreen(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.usuarioHome: return const UsuarioHomeScreen();
      case AppRoutes.usuarioNuevaIncidencia: return const NuevaIncidenciaScreen();
      case AppRoutes.usuarioDetalleIncidencia: return DetalleIncidenciaUsuarioScreen(incidenciaId: args as int);
      case AppRoutes.tecnicoHome: return const TecnicoHomeScreen();
      case AppRoutes.tecnicoDetalleIncidencia: return TecnicoDetalleScreen(incidenciaId: args as int);
      case AppRoutes.adminHome: return const AdminHomeScreen();
      case AppRoutes.adminDetalleIncidencia: return AdminDetalleScreen(incidenciaId: args as int);
      case AppRoutes.adminReportes: return const AdminReportesScreen();
      default: return const Scaffold(body: Center(child: Text('Ruta no encontrada.')));
    }
  }

  static Widget _accesoNegado(String rolActual) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso Denegado')),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.lock, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          const Text('No tienes permiso para acceder a esta sección.', textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Tu rol actual: $rolActual', style: const TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }
}

// ── Splash / router inicial ────────────────────────────────────────────────
class _SplashRouter extends StatefulWidget {
  const _SplashRouter();
  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final auth = AuthService();

    if (!ENABLE_ROUTE_GUARDS) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    final loggedIn = await auth.isLoggedIn();
    if (!loggedIn) { Navigator.pushReplacementNamed(context, AppRoutes.login); return; }
    final usuario = await auth.getUsuario();
    if (usuario == null) { Navigator.pushReplacementNamed(context, AppRoutes.login); return; }

    switch (usuario.rol) {
      case 'USUARIO': Navigator.pushReplacementNamed(context, AppRoutes.usuarioHome); break;
      case 'TECNICO': Navigator.pushReplacementNamed(context, AppRoutes.tecnicoHome); break;
      case 'SUPERVISOR': Navigator.pushReplacementNamed(context, AppRoutes.adminHome); break;
      default: Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.support_agent, size: 80, color: Color(0xFF1565C0)),
        SizedBox(height: 16),
        Text('Gestión de Incidencias', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 24),
        CircularProgressIndicator(),
      ])),
    );
  }
}

// Resultado de resolución de ruta
class _RouteResult {
  final Widget? widget;
  final String? redirect;
  const _RouteResult({this.widget, this.redirect});
}
