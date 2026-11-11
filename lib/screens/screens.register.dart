import 'package:flutter/material.dart';

import '../components/components.brand_logo.dart';
import '../components/components.custom_input.dart';
import '../services/services.api.dart';
import '../services/services.storage.dart';
import 'screens.home.dart';
import 'screens.login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = ApiService();
  final _storage = StorageService();
  bool _hidePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
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

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Digite seu nome.';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < 8) return 'Use pelo menos 8 caracteres.';
    if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password)) {
      return 'Inclua pelo menos uma letra e um número.';
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final name = _nameController.text.trim();
      await _api.cadastrarUsuario(
        nome: name,
        email: _emailController.text,
        senha: _passwordController.text,
      );
      try {
        await _storage.salvarNomeUsuario(name);
      } catch (_) {
        // O cadastro remoto continua válido se a preferência local falhar.
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível concluir o cadastro: $error')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
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
                      'Crie sua conta',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cadastre-se para entrar na Feira Otaku.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF765C49),
                      ),
                    ),
                    const SizedBox(height: 28),
                    CustomInput(
                      controller: _nameController,
                      label: 'Nome',
                      hint: 'Como podemos chamar você?',
                      icon: Icons.person_outline,
                      validator: _validateName,
                    ),
                    const SizedBox(height: 14),
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
                      hint: 'Mínimo de 8 caracteres',
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
                    const SizedBox(height: 8),
                    Text(
                      'A senha precisa ter ao menos 8 caracteres, uma letra e um número.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF765C49),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _submitting ? null : _register,
                      icon: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.person_add_alt_1_rounded),
                      label: Text(
                        _submitting ? 'Cadastrando...' : 'Criar conta',
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _openLogin,
                      child: const Text('Já possui uma conta? Entrar'),
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
