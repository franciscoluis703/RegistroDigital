
// lib/app/routes/routes.dart
import 'package:flutter/material.dart';

import '../presentation/modules/home/views/home_screen.dart';
import '../presentation/modules/student/general_info/views/general_info_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.generalInfo:
        return MaterialPageRoute(builder: (_) => const GeneralInfoScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
