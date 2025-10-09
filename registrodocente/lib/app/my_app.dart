import 'package:flutter/material.dart';

import 'presentation/routes/app_routes.dart';
import 'presentation/routes/routes.dart';
import 'presentation/themes/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro Docente',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      routes: appRoutes,
      theme: AppTheme.lightTheme,
    );
  }
}