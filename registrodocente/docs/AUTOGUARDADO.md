# Sistema de Autoguardado Automático

## Descripción

El sistema implementa **autoguardado automático** en todas las pantallas de la aplicación. Los cambios del usuario se guardan automáticamente en Supabase después de 2 segundos de inactividad, sin necesidad de presionar botones de "Guardar".

## Características

✅ **Guardado automático con debouncing** - Espera 2 segundos después del último cambio
✅ **Indicador visual de estado** - Muestra "Guardando...", "Guardado", o "Error"
✅ **Sin pérdida de datos** - Todo se guarda automáticamente en tiempo real
✅ **Optimizado** - Evita guardados innecesarios mientras el usuario escribe
✅ **Feedback claro** - El usuario siempre sabe el estado de sus cambios

## Arquitectura

### 1. AutoSaveController

Controlador que gestiona el estado y la lógica del autoguardado.

**Ubicación**: `lib/app/core/utils/auto_save_controller.dart`

**Estados**:
- `idle`: Sin cambios pendientes
- `pending`: Hay cambios que se guardarán pronto
- `saving`: Guardando en progreso
- `saved`: Guardado exitoso
- `error`: Error al guardar

**Uso**:
```dart
final controller = AutoSaveController(
  debounceDuration: Duration(seconds: 2),
  onSave: () async {
    // Lógica para guardar datos
    return true; // o false si hay error
  },
);

// Notificar un cambio
controller.markAsChanged(); // Espera 2 segundos y guarda

// Guardar inmediatamente
await controller.saveNow();
```

### 2. AutoSaveIndicator

Widget que muestra visualmente el estado del guardado.

**Ubicación**: `lib/app/core/widgets/auto_save_indicator.dart`

**Modos**:
- `compact: false`: Muestra icono + texto (ej: "Guardando...")
- `compact: true`: Solo muestra icono

**Uso**:
```dart
AutoSaveIndicator(
  controller: autoSaveController,
  compact: false,
)
```

### 3. AutoSaveMixin

Mixin que facilita agregar autoguardado a cualquier pantalla.

**Ubicación**: `lib/app/core/mixins/auto_save_mixin.dart`

**Funcionalidades**:
- Gestión automática del `AutoSaveController`
- Métodos helper para crear widgets con autoguardado
- `notifyChange()` - Marca que hubo un cambio
- `saveNow()` - Guarda inmediatamente

## Cómo Implementar Autoguardado en una Pantalla

### Paso 1: Agregar el Mixin

```dart
class MiPantallaState extends State<MiPantalla> with AutoSaveMixin {
  // ...
}
```

### Paso 2: Implementar createAutoSaveController

```dart
@override
AutoSaveController createAutoSaveController() {
  return AutoSaveController(
    debounceDuration: const Duration(seconds: 2),
    onSave: _guardarDatos,
  );
}

Future<bool> _guardarDatos() async {
  // Tu lógica de guardado aquí
  final result = await miServicio.actualizar(datos);
  return result != null;
}
```

### Paso 3: Agregar Indicador Visual

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Mi Pantalla'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: AutoSaveIndicator(controller: autoSaveController),
          ),
        ),
      ],
    ),
    // ...
  );
}
```

### Paso 4: Notificar Cambios

```dart
TextField(
  controller: _miController,
  onChanged: (_) => notifyChange(), // ¡Esto activa el autoguardado!
  // ...
)

// O para dropdowns, checkboxes, etc:
DropdownButton(
  onChanged: (value) {
    setState(() => _valor = value);
    notifyChange(); // ¡Activa el autoguardado!
  },
)
```

## Ejemplo Completo: Pantalla de Perfil

```dart
import 'package:flutter/material.dart';
import '../../../../core/mixins/auto_save_mixin.dart';
import '../../../../core/utils/auto_save_controller.dart';
import '../../../../core/widgets/auto_save_indicator.dart';
import '../../../../data/services/perfil_supabase_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> with AutoSaveMixin {
  final _perfilService = PerfilSupabaseService();
  final TextEditingController _nombreController = TextEditingController();

  @override
  AutoSaveController createAutoSaveController() {
    return AutoSaveController(
      debounceDuration: const Duration(seconds: 2),
      onSave: _guardarDatos,
    );
  }

  Future<bool> _guardarDatos() async {
    final result = await _perfilService.actualizarPerfil(
      nombre: _nombreController.text.trim(),
    );
    return result != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: AutoSaveIndicator(controller: autoSaveController),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              onChanged: (_) => notifyChange(),
              decoration: const InputDecoration(
                labelText: 'Nombre',
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Los cambios se guardan automáticamente',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Pantallas con Autoguardado Implementado

✅ **PerfilScreen** - Perfil de usuario

## Pantallas Pendientes

Las siguientes pantallas pueden beneficiarse del autoguardado:

- [ ] **General Info Screen** - Información general de estudiantes
- [ ] **Centro Educativo Screen** - Datos del centro educativo
- [ ] **Emergency Data Screen** - Datos de emergencia
- [ ] **Asistencia Screen** - Registro de asistencias
- [ ] **Calificaciones Screen** - Registro de calificaciones
- [ ] **Horario Clase Screen** - Gestión de horarios

## Mejores Prácticas

### ✅ DO (Hacer)

1. **Siempre usar `notifyChange()`** cuando cambie un valor
2. **Agregar indicador visual** para que el usuario vea el estado
3. **Mostrar mensaje informativo** "Los cambios se guardan automáticamente"
4. **Manejar errores** en la función `onSave`
5. **Validar datos** antes de guardar

### ❌ DON'T (No hacer)

1. **No guardar en cada tecla** - Usa debouncing (ya implementado)
2. **No omitir el indicador** - El usuario debe saber qué pasa
3. **No ignorar errores** - Siempre mostrar si algo falló
4. **No hacer llamadas innecesarias** - El controller ya optimiza esto
5. **No mezclar autoguardado con botones** - Elige uno u otro

## Personalización

### Cambiar el tiempo de espera

```dart
AutoSaveController(
  debounceDuration: const Duration(seconds: 3), // 3 segundos en lugar de 2
  onSave: _guardarDatos,
)
```

### Guardar inmediatamente en eventos específicos

```dart
void _alSalirDeLaPantalla() async {
  await saveNow(); // Guarda inmediatamente sin esperar
  Navigator.pop(context);
}
```

### Indicador compacto

```dart
AutoSaveIndicator(
  controller: autoSaveController,
  compact: true, // Solo muestra iconos, sin texto
)
```

## Integración con Supabase

El autoguardado funciona perfectamente con los servicios de Supabase:

```dart
Future<bool> _guardarDatos() async {
  try {
    final result = await _miServicioSupabase.actualizar(
      id: _id,
      datos: {
        'campo1': _valor1,
        'campo2': _valor2,
      },
    );
    return result != null;
  } catch (e) {
    // Error será manejado automáticamente
    return false;
  }
}
```

## Debugging

Para ver el estado del autoguardado en tiempo real:

```dart
// En tu widget
ListenableBuilder(
  listenable: autoSaveController,
  builder: (context, _) {
    print('Estado actual: ${autoSaveController.status}');
    return YourWidget();
  },
)
```

## FAQ

**P: ¿Qué pasa si el usuario cierra la app mientras está guardando?**
R: El cambio puede perderse. Para casos críticos, llama a `saveNow()` antes de cerrar.

**P: ¿Funciona sin conexión?**
R: No, requiere conexión a Supabase. Se puede extender para guardar localmente y sincronizar después.

**P: ¿Puedo tener múltiples controladores en la misma pantalla?**
R: Sí, pero generalmente un controlador por pantalla es suficiente.

**P: ¿Cómo saber si hubo un error al guardar?**
R: El indicador muestra un icono rojo de error automáticamente.

---

**Última actualización**: 2025-10-05
**Versión**: 1.0
**Responsable**: Sistema de Registro Docente
