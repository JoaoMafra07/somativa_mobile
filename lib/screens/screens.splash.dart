import 'dart:async';

import 'package:flutter/material.dart';

import '../components/components.brand_logo.dart';
import 'screens.login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), _openLogin);
  }

  void _openLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF9F4), Color(0xFFFFE9D4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandLogo(size: 126),
                const SizedBox(height: 24),
                Text(
                  'FEIRA OTAKU',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFFB84E00),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Seu próximo item favorito está aqui.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF765C49),
                  ),
                ),
                const SizedBox(height: 34),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
