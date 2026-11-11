import 'package:flutter/material.dart';

import 'screens/screens.splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CatalogoApp());
}

class CatalogoApp extends StatelessWidget {
  const CatalogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const laranja = Color(0xFFEF6C00);

    return MaterialApp(
      title: 'Feira Otaku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: laranja,
          primary: laranja,
          surface: const Color(0xFFFFF9F4),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF9F4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFF9F4),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF0E4D8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF0E4D8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: laranja, width: 1.5),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
