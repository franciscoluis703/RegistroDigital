// REGISTRO DOCENTE - Aplicación Web
// https://registrodigital.online
//
// FIREBASE/FIRESTORE BACKEND
// ================================
// Backend Principal: Firebase/Firestore
// - Autenticación: Firebase Auth (Email/Password, Google)
// - Base de datos: Cloud Firestore (sincronización en tiempo real)
// - Almacenamiento: Firebase Storage (fotos y archivos)
// - Analytics: Firebase Analytics
//
// ✅ Migración completada - Supabase eliminado
// Todas las funcionalidades principales migradas a Firebase

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'app/domain/repositories/connectivity_repository.dart';
import 'app/data/repositories_implementation/connectivity_repository_impl.dart';
// AdMob deshabilitado temporalmente para solucionar problemas en web
// import 'app/data/services/ads_service_web.dart' if (dart.library.io) 'app/data/services/ads_service.dart';
import 'app/core/providers/user_provider.dart';
import 'app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================
  // INICIALIZAR FIREBASE (Backend Principal)
  // ==========================================
  // Firebase es el backend principal de la aplicación
  // Proporciona: Auth, Firestore, Storage, Analytics
  try {
    // Verificar si Firebase ya está inicializado
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase inicializado correctamente');
      debugPrint('   - Authentication: Habilitado');
      debugPrint('   - Firestore: Habilitado');
      debugPrint('   - Storage: Habilitado');
      debugPrint('   - Analytics: Habilitado');

      // ==========================================
      // CONFIGURAR PERSISTENCIA OFFLINE DE FIRESTORE
      // ==========================================
      // Habilitar persistencia local automática
      // Los datos se guardan localmente y se sincronizan automáticamente
      // cuando hay conexión a internet
      try {
        // Para web, la persistencia se habilita con enablePersistence
        if (kIsWeb) {
          await FirebaseFirestore.instance.enablePersistence(
            const PersistenceSettings(synchronizeTabs: true),
          );
          debugPrint('✅ Persistencia offline habilitada (Web)');
        } else {
          // Para móvil y desktop, la persistencia está habilitada por defecto
          // pero podemos configurar el tamaño del caché
          FirebaseFirestore.instance.settings = const Settings(
            persistenceEnabled: true,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          );
          debugPrint('✅ Persistencia offline habilitada (Nativo)');
        }

        debugPrint('📱 Todos los datos se guardan automáticamente');
        debugPrint('🔄 Sincronización automática entre dispositivos');
        debugPrint('💾 Los datos persisten permanentemente en Firebase');
      } catch (e) {
        debugPrint('⚠️ Advertencia de persistencia: $e');
        // No es crítico, continuar
      }
    } else {
      debugPrint('ℹ️ Firebase ya está inicializado');
    }
  } catch (e) {
    debugPrint('❌ ERROR CRÍTICO: Firebase no se pudo inicializar: $e');
    // Firebase es CRÍTICO - sin él la app no funcionará
    rethrow;
  }

  // ==========================================
  // SUPABASE ELIMINADO
  // ==========================================
  // ✅ Migración completada - Supabase ha sido eliminado
  // Todas las 13 pantallas principales migradas a Firebase

  // ==========================================
  // ADMOB DESHABILITADO TEMPORALMENTE
  // ==========================================
  // AdMob está deshabilitado temporalmente para solucionar problemas en web
  // TODO: Reactivar AdMob solo para móviles después de confirmar que web funciona
  // try {
  //   await AdsService.initialize();
  //   debugPrint('✅ AdMob inicializado correctamente');
  // } catch (e) {
  //   debugPrint('⚠️ Error al inicializar AdMob: $e');
  // }
  debugPrint('ℹ️ AdMob deshabilitado temporalmente');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Injector(
        connectivityRepository: connectivityRepository,
        child: const MyApp(),
      ),
    ),
  );
}


class Injector extends InheritedWidget {
  const Injector({
    super.key,
    required super.child,
    required this.connectivityRepository,
  });

  final ConnectivityRepository connectivityRepository;


  @override
  bool updateShouldNotify(_) => false;


  static Injector of(BuildContext context) {
    final injector = context.dependOnInheritedWidgetOfExactType<Injector>();
    assert(injector != null, 'Injector could not found');
    return injector!;
  }
}