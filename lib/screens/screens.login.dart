import 'package:flutter/material.dart';

import '../components/components.brand_logo.dart';
import '../components/components.custom_input.dart';
import '../services/services.api.dart';
import '../services/services.storage.dart';
import 'screens.home.dart';
import 'screens.register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = ApiService();
  final _storage = StorageService();
  bool _hidePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Digite um e-mail válido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Informe sua senha.';
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final user = await _api.autenticarUsuario(
        email: _emailController.text,
        senha: _passwordController.text,
      );
      if (!mounted) return;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail ou senha incorretos.')),
        );
        return;
      }
      try {
        final name = user['nome']?.toString().trim();
        if (name != null && name.isNotEmpty) {
          await _storage.salvarNomeUsuario(name);
        }
      } catch (_) {
        // A preferência do nome não impede o login remoto.
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível entrar: $error')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _openRegistration() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: BrandLogo(size: 76)),
                    const SizedBox(height: 24),
                    Text(
                      'Entre na Feira Otaku',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Acesse sua conta para explorar o catálogo.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF765C49),
                      ),
                    ),
                    const SizedBox(height: 28),
                    CustomInput(
                      controller: _emailController,
                      label: 'E-mail',
                      hint: 'voce@exemplo.com',
                      icon: Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 14),
                    CustomInput(
                      controller: _passwordController,
                      label: 'Senha',
                      icon: Icons.lock_outline,
                      obscureText: _hidePassword,
                      suffixIcon: IconButton(
                        tooltip: _hidePassword
                            ? 'Mostrar senha'
                            : 'Ocultar senha',
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _submitting ? null : _login,
                      icon: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login_rounded),
                      label: Text(_submitting ? 'Entrando...' : 'Entrar'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _openRegistration,
                      child: const Text('Não possui uma conta? Clique aqui'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
