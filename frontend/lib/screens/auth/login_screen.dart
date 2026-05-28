import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../config/routes.dart';
import '../../widgets/loading_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _auth.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      if (result['ok'] == true) {
        final rol = result['usuario']['rol'];
        switch (rol) {
          case 'USUARIO': Navigator.pushNamedAndRemoveUntil(context, AppRoutes.usuarioHome, (_) => false); break;
          case 'TECNICO': Navigator.pushNamedAndRemoveUntil(context, AppRoutes.tecnicoHome, (_) => false); break;
          case 'SUPERVISOR': Navigator.pushNamedAndRemoveUntil(context, AppRoutes.adminHome, (_) => false); break;
        }
      } else {
        setState(() { _error = result['message'] ?? 'Error al iniciar sesión.'; });
      }
    } catch (e) {
      setState(() { _error = 'No se pudo conectar con el servidor.'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.support_agent, size: 64, color: Color(0xFF1565C0)),
                      const SizedBox(height: 8),
                      const Text('Gestión de Incidencias', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Inicia sesión para continuar', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                          child: Row(children: [const Icon(Icons.error_outline, color: Colors.red), const SizedBox(width: 8), Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red)))]),
                        ),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                        validator: (v) => (v == null || !v.contains('@')) ? 'Email inválido.' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscure = !_obscure)),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Contraseña requerida.' : null,
                      ),
                      const SizedBox(height: 24),
                      LoadingButton(loading: _loading, label: 'Iniciar Sesión', onPressed: _login),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
