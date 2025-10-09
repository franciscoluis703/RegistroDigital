# Guía de Implementación - Persistencia Total con Supabase
## Registro Docente - Sistema Completo de Sincronización

---

## 📋 Índice
1. [Configuración Inicial](#1-configuración-inicial)
2. [Configurar Supabase](#2-configurar-supabase)
3. [Actualizar Dependencias](#3-actualizar-dependencias)
4. [Implementar Autenticación](#4-implementar-autenticación)
5. [Migrar Servicios Existentes](#5-migrar-servicios-existentes)
6. [Sincronización Offline](#6-sincronización-offline)
7. [Testing y Verificación](#7-testing-y-verificación)

---

## 1. Configuración Inicial

### 1.1 Obtener Credenciales de Supabase

1. Ve a [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Crea un nuevo proyecto o selecciona el existente
3. Ve a **Settings** > **API**
4. Copia:
   - `Project URL` (ejemplo: https://abcdefgh.supabase.co)
   - `anon` key (clave pública)
   - `service_role` key (clave secreta - **NUNCA compartir**)

### 1.2 Configurar Variables de Entorno

Crea el archivo `.env` en la raíz del proyecto:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key-aqui
```

**IMPORTANTE:** Agrega `.env` al `.gitignore` para no subir las credenciales al repositorio.

---

## 2. Configurar Supabase

### 2.1 Ejecutar Script SQL

1. Ve a tu proyecto en Supabase Dashboard
2. Click en **SQL Editor** en el menú lateral
3. Click en **New Query**
4. Copia todo el contenido del archivo `supabase_persistencia_completa.sql`
5. Pega en el editor y haz click en **Run**
6. Verifica que todas las tablas se hayan creado correctamente

### 2.2 Verificar RLS (Row Level Security)

1. Ve a **Database** > **Tables**
2. Para cada tabla, verifica que RLS esté habilitado (ícono de candado verde)
3. Click en una tabla > **Policies** para ver las políticas de seguridad

### 2.3 Configurar Auth Providers (Opcional)

Si quieres permitir login con Google:

1. Ve a **Authentication** > **Providers**
2. Habilita **Google**
3. Configura las credenciales de OAuth de Google Cloud Console
4. Agrega tu dominio en **Authorized redirect URIs**:
   - `https://registrodigital.online/auth/callback`
   - `http://localhost:3000/auth/callback` (para desarrollo)

---

## 3. Actualizar Dependencias

### 3.1 Agregar Dependencias en `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Supabase
  supabase_flutter: ^2.0.0

  # Persistencia local
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2

  # Variables de entorno
  flutter_dotenv: ^5.1.0

  # Otras dependencias existentes...

dev_dependencies:
  # Para generar adaptadores de Hive
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

### 3.2 Instalar Dependencias

```bash
flutter pub get
```

---

## 4. Implementar Autenticación

### 4.1 Inicializar Supabase en `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  // Inicializar Hive para persistencia local
  await Hive.initFlutter();

  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // Más seguro para aplicaciones móviles/web
    ),
  );

  runApp(const MyApp());
}
```

### 4.2 Crear Pantalla de Login

Crear `lib/app/presentation/modules/auth/views/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // Navegar a home
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    final result = await _authService.signInWithGoogle();

    setState(() => _isLoading = false);

    if (!result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                const Icon(Icons.school, size: 100, color: Color(0xFFbfa661)),
                const SizedBox(height: 24),
                const Text(
                  'Registro Docente',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 48),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu correo';
                    }
                    if (!value.contains('@')) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botón Login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFbfa661),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón Google
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Continuar con Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 16),

                // Recuperar contraseña
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),

                // Registro
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('¿No tienes cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 4.3 Actualizar Rutas en `app_routes.dart`

```dart
import 'package:flutter/material.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/register_screen.dart';
import '../modules/auth/views/forgot_password_screen.dart';
// ... otras importaciones

class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  // ... otras rutas

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    home: (context) => const HomeScreen(),
    // ... otras rutas
  };
}
```

### 4.4 Proteger Rutas con AuthGuard

Crear `lib/app/core/guards/auth_guard.dart`:

```dart
import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    if (!authService.isAuthenticated) {
      // Redirigir a login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return child;
  }
}
```

Usar en las rutas protegidas:

```dart
home: (context) => AuthGuard(child: const HomeScreen()),
```

---

## 5. Migrar Servicios Existentes

### 5.1 Patrón de Migración

Para cada servicio existente (ejemplo: `estudiantes_service.dart`), seguir este patrón:

**ANTES (con SharedPreferences):**
```dart
Future<List<Map<String, dynamic>>> obtenerEstudiantes() async {
  final prefs = await SharedPreferences.getInstance();
  final estudiantesJson = prefs.getString('estudiantes');
  // ...
}
```

**DESPUÉS (con Supabase):**
```dart
Future<List<Map<String, dynamic>>> obtenerEstudiantes() async {
  final userId = AuthService().currentUserId;
  if (userId == null) return [];

  try {
    final response = await _supabase
        .from('estudiantes')
        .select()
        .eq('user_id', userId)
        .order('numero', ascending: true);

    // Registrar actividad
    await ActivityLogService().log(
      action: 'read',
      entityType: 'estudiantes',
      details: {'count': (response as List).length},
    );

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Error al obtener estudiantes: $e');
    return [];
  }
}
```

### 5.2 Ejemplo Completo: Estudiantes Service

Crear `lib/app/data/services/remote/estudiantes_supabase_service.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth_service.dart';
import '../activity_log_service.dart';

class EstudiantesSupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();
  final ActivityLogService _activityLog = ActivityLogService();

  String? get _userId => _authService.currentUserId;

  // Obtener todos los estudiantes de un curso
  Future<List<Map<String, dynamic>>> obtenerEstudiantes(String cursoId) async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('estudiantes')
          .select()
          .eq('user_id', _userId!)
          .eq('curso_id', cursoId)
          .order('numero', ascending: true);

      await _activityLog.log(
        action: 'read',
        entityType: 'estudiantes',
        entityId: cursoId,
        details: {'count': (response as List).length},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener estudiantes: $e');
      return [];
    }
  }

  // Crear estudiante
  Future<Map<String, dynamic>> crearEstudiante({
    required String cursoId,
    required int numero,
    required String nombreCompleto,
    String? cedula,
    DateTime? fechaNacimiento,
    // ... otros campos
  }) async {
    if (_userId == null) {
      return {'success': false, 'message': 'Usuario no autenticado'};
    }

    try {
      final data = {
        'user_id': _userId,
        'curso_id': cursoId,
        'numero': numero,
        'nombre_completo': nombreCompleto,
        'cedula': cedula,
        'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('estudiantes')
          .insert(data)
          .select()
          .single();

      await _activityLog.log(
        action: 'create',
        entityType: 'estudiantes',
        entityId: response['id'],
        details: {'nombre': nombreCompleto, 'numero': numero},
      );

      return {
        'success': true,
        'data': response,
        'message': 'Estudiante creado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al crear estudiante: $e',
      };
    }
  }

  // Actualizar estudiante
  Future<Map<String, dynamic>> actualizarEstudiante(
    String estudianteId,
    Map<String, dynamic> updates,
  ) async {
    if (_userId == null) {
      return {'success': false, 'message': 'Usuario no autenticado'};
    }

    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('estudiantes')
          .update(updates)
          .eq('id', estudianteId)
          .eq('user_id', _userId!)
          .select()
          .single();

      await _activityLog.log(
        action: 'update',
        entityType: 'estudiantes',
        entityId: estudianteId,
        details: updates,
      );

      return {
        'success': true,
        'data': response,
        'message': 'Estudiante actualizado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al actualizar estudiante: $e',
      };
    }
  }

  // Eliminar estudiante
  Future<Map<String, dynamic>> eliminarEstudiante(String estudianteId) async {
    if (_userId == null) {
      return {'success': false, 'message': 'Usuario no autenticado'};
    }

    try {
      await _supabase
          .from('estudiantes')
          .delete()
          .eq('id', estudianteId)
          .eq('user_id', _userId!);

      await _activityLog.log(
        action: 'delete',
        entityType: 'estudiantes',
        entityId: estudianteId,
      );

      return {
        'success': true,
        'message': 'Estudiante eliminado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al eliminar estudiante: $e',
      };
    }
  }

  // Obtener nombres de estudiantes (para widgets de vista rápida)
  Future<List<String>> obtenerNombresEstudiantes(String cursoId) async {
    final estudiantes = await obtenerEstudiantes(cursoId);
    return estudiantes.map((e) => e['nombre_completo'] as String).toList();
  }
}
```

### 5.3 Servicios a Migrar

Repetir el patrón anterior para:

1. ✅ `estudiantes_supabase_service.dart` (ejemplo arriba)
2. ⏳ `asistencia_supabase_service.dart`
3. ⏳ `calificaciones_supabase_service.dart`
4. ⏳ `horarios_supabase_service.dart`
5. ⏳ `promocion_grado_supabase_service.dart`
6. ⏳ `cursos_supabase_service.dart`

---

## 6. Sincronización Offline

### 6.1 Inicializar Hive

En `main.dart`:

```dart
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  // ... código existente

  await Hive.initFlutter();

  // Registrar adaptadores (si usas modelos personalizados)
  // Hive.registerAdapter(EstudianteAdapter());

  runApp(const MyApp());
}
```

### 6.2 Crear Servicio de Sincronización

Crear `lib/app/data/services/sync_service.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'auth_service.dart';
import 'activity_log_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();
  final ActivityLogService _activityLog = ActivityLogService();

  bool _isSyncing = false;

  // Verificar conectividad
  Future<bool> hasConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Guardar operación pendiente (cuando no hay internet)
  Future<void> queueOperation({
    required String operation, // insert, update, delete
    required String tableName,
    required Map<String, dynamic> data,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    final box = await Hive.openBox('sync_queue');

    await box.add({
      'user_id': userId,
      'operation': operation,
      'table_name': tableName,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'pending',
    });

    // Intentar sincronizar inmediatamente
    await syncPendingOperations();
  }

  // Sincronizar operaciones pendientes
  Future<void> syncPendingOperations() async {
    if (_isSyncing) return;
    if (!await hasConnection()) return;

    _isSyncing = true;

    try {
      final box = await Hive.openBox('sync_queue');
      final pendingOps = box.values
          .where((op) => op['status'] == 'pending')
          .toList();

      for (var i = 0; i < pendingOps.length; i++) {
        final op = pendingOps[i];

        try {
          await _executeOperation(
            op['operation'],
            op['table_name'],
            op['data'],
          );

          // Marcar como completada
          final key = box.keys.elementAt(i);
          await box.put(key, {...op, 'status': 'completed'});
        } catch (e) {
          // Marcar como fallida
          final key = box.keys.elementAt(i);
          await box.put(key, {...op, 'status': 'failed', 'error': e.toString()});
        }
      }

      // Limpiar operaciones completadas después de 7 días
      await _cleanOldOperations(box);
    } finally {
      _isSyncing = false;
    }
  }

  // Ejecutar operación en Supabase
  Future<void> _executeOperation(
    String operation,
    String tableName,
    Map<String, dynamic> data,
  ) async {
    switch (operation) {
      case 'insert':
        await _supabase.from(tableName).insert(data);
        break;
      case 'update':
        final id = data['id'];
        data.remove('id');
        await _supabase.from(tableName).update(data).eq('id', id);
        break;
      case 'delete':
        await _supabase.from(tableName).delete().eq('id', data['id']);
        break;
    }
  }

  // Limpiar operaciones antiguas
  Future<void> _cleanOldOperations(Box box) async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));

    final keysToDelete = <dynamic>[];
    for (var key in box.keys) {
      final op = box.get(key);
      if (op['status'] == 'completed') {
        final timestamp = DateTime.parse(op['timestamp']);
        if (timestamp.isBefore(cutoffDate)) {
          keysToDelete.add(key);
        }
      }
    }

    for (var key in keysToDelete) {
      await box.delete(key);
    }
  }

  // Obtener estadísticas de sincronización
  Future<Map<String, int>> getSyncStats() async {
    final box = await Hive.openBox('sync_queue');

    int pending = 0;
    int completed = 0;
    int failed = 0;

    for (var op in box.values) {
      switch (op['status']) {
        case 'pending':
          pending++;
          break;
        case 'completed':
          completed++;
          break;
        case 'failed':
          failed++;
          break;
      }
    }

    return {
      'pending': pending,
      'completed': completed,
      'failed': failed,
      'total': box.length,
    };
  }
}
```

### 6.3 Usar Sincronización en Servicios

Modificar servicios para usar la cola cuando no hay conexión:

```dart
Future<Map<String, dynamic>> crearEstudiante(...) async {
  final hasInternet = await SyncService().hasConnection();

  if (!hasInternet) {
    // Guardar en cola de sincronización
    await SyncService().queueOperation(
      operation: 'insert',
      tableName: 'estudiantes',
      data: {
        'user_id': _userId,
        'curso_id': cursoId,
        'numero': numero,
        'nombre_completo': nombreCompleto,
        // ... otros campos
      },
    );

    return {
      'success': true,
      'message': 'Estudiante guardado. Se sincronizará cuando haya conexión.',
    };
  }

  // Si hay internet, crear directamente
  // ... código normal de creación
}
```

---

## 7. Testing y Verificación

### 7.1 Checklist de Verificación

- [ ] Script SQL ejecutado correctamente en Supabase
- [ ] RLS habilitado en todas las tablas
- [ ] Auth providers configurados (Google, etc.)
- [ ] Variables de entorno configuradas (.env)
- [ ] Dependencias instaladas
- [ ] Supabase inicializado en main.dart
- [ ] Pantalla de login funcional
- [ ] Registro de usuario funcional
- [ ] Logout funcional
- [ ] Perfil de usuario se carga correctamente
- [ ] Datos aislados por usuario (verificar con 2 cuentas)
- [ ] Logs de actividad se registran
- [ ] Sincronización offline funciona
- [ ] Datos persisten después de cerrar y abrir app

### 7.2 Testing con 2 Usuarios

1. Crear usuario 1 y agregar datos
2. Cerrar sesión
3. Crear usuario 2 y agregar datos
4. Verificar que usuario 2 NO vea datos de usuario 1
5. Volver a usuario 1 y verificar que sus datos sigan ahí

### 7.3 Testing de Sincronización Offline

1. Desactivar internet
2. Crear/editar datos
3. Verificar que se guarden en cola
4. Reactivar internet
5. Verificar que los datos se sincronicen automáticamente

---

## 8. Despliegue

### 8.1 Build para Producción

```bash
flutter build web --release
```

### 8.2 Deploy a Firebase

```bash
firebase deploy --only hosting
```

### 8.3 Configurar Dominio

El dominio `registrodigital.online` ya está configurado siguiendo las instrucciones en `CONFIGURACION_DOMINIO.md`.

---

## 9. Mantenimiento

### 9.1 Backup de Base de Datos

En Supabase Dashboard:
1. **Database** > **Backups**
2. Configurar backups automáticos diarios

### 9.2 Monitoreo

1. **Database** > **Table Editor** para ver datos
2. **SQL Editor** > **Query** para analytics
3. **Auth** > **Users** para ver usuarios registrados
4. **Logs** para ver errores y actividad

---

## 10. Troubleshooting

### Problema: "Usuario no autenticado"
**Solución:** Verificar que Supabase esté inicializado en main.dart y que el usuario haya iniciado sesión.

### Problema: "RLS policy violation"
**Solución:** Verificar que las políticas RLS permitan al usuario acceder a sus propios datos. Verificar que `user_id` coincida con `auth.uid()`.

### Problema: Datos no se sincronizan
**Solución:** Revisar cola de sincronización con `SyncService().getSyncStats()` y logs de errores.

### Problema: "Invalid JWT"
**Solución:** El token expiró. Llamar a `AuthService().refreshSession()`.

---

## 📚 Recursos Adicionales

- [Documentación de Supabase](https://supabase.com/docs)
- [Flutter + Supabase Tutorial](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Hive Documentation](https://docs.hivedb.dev/)

---

**¡Implementación completa!** 🎉

Tu aplicación ahora tiene:
✅ Autenticación persistente
✅ Datos completamente aislados por usuario
✅ Sincronización en tiempo real con Supabase
✅ Soporte offline con cola de sincronización
✅ Logs de actividad completos
✅ Seguridad con RLS
