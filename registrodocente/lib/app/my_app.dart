import 'package:flutter/material.dart';

import 'presentation/routes/app_routes.dart';
import 'presentation/routes/routes.dart';
// import 'presentation/themes/app_theme.dart'; // Temporalmente deshabilitado para debug

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro Digital',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.signIn,
      routes: appRoutes,
      // Tema básico sin GoogleFonts para debugging
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
    );
  }
}