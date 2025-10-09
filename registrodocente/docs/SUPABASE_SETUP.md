# 🚀 Guía de Configuración de Supabase

## Paso 1: Obtener credenciales de Supabase

1. Ve a tu dashboard de Supabase: https://supabase.com/dashboard/project/fqghquowfozmmbohhzebb

2. Click en **Project Settings** (⚙️ en la barra lateral izquierda)

3. Click en **API** en el menú lateral

4. Copia estos dos valores:
   - **Project URL** (algo como: `https://fqghquowfozmmbohhzebb.supabase.co`)
   - **Anon public key** (una clave larga que empieza con `eyJ...`)

## Paso 2: Configurar credenciales en la app

1. Abre el archivo: `lib/app/config/supabase_config.dart`

2. Reemplaza los valores:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://TU_URL.supabase.co';
  static const String supabaseAnonKey = 'eyJ... TU CLAVE AQUI ...';
}
```

## Paso 3: Crear las tablas en Supabase

1. En tu dashboard de Supabase, ve a **SQL Editor** (icono de </> en la barra lateral)

2. Click en **New Query**

3. Copia TODO el contenido del archivo `supabase_schema.sql`

4. Pégalo en el editor SQL

5. Click en **Run** (o presiona Ctrl/Cmd + Enter)

6. Verifica que aparezca "Success. No rows returned" (es normal)

7. Ve a **Table Editor** y verifica que se crearon las tablas:
   - ✅ docentes
   - ✅ cursos
   - ✅ estudiantes
   - ✅ asistencias
   - ✅ calificaciones
   - ✅ evaluaciones
   - ✅ datos_emergencia
   - ✅ parentesco

## Paso 4: Verificar Row Level Security (RLS)

1. En **Table Editor**, selecciona cualquier tabla (ej: `cursos`)

2. Verifica que diga "RLS enabled" (icono de candado verde)

3. Esto garantiza que cada docente solo vea sus propios datos

## Paso 5: Configurar autenticación

1. Ve a **Authentication** → **Providers**

2. Habilita **Email** (debe estar ya habilitado por defecto)

3. Opcional: Configura proveedores sociales (Google, Apple, etc.)

## Paso 6: Probar la conexión

1. Ejecuta la aplicación: `flutter run`

2. Intenta crear una cuenta o iniciar sesión

3. Si funciona correctamente, verás que:
   - Los datos se guardan en Supabase
   - Cada usuario tiene sus datos separados
   - Los datos persisten entre sesiones

## Estructura de Datos

### Flujo de datos:

```
Usuario (auth.users)
    ↓
Docente (docentes table)
    ↓
Cursos (cursos table)
    ↓
Estudiantes (estudiantes table)
    ↓
├─ Asistencias
├─ Calificaciones
├─ Datos Emergencia
└─ Parentesco
```

### Características de Seguridad:

✅ **Row Level Security (RLS)**: Cada docente solo ve sus datos
✅ **Cascading Deletes**: Si borras un curso, se borran sus estudiantes
✅ **Índices**: Optimizado para consultas rápidas
✅ **Timestamps**: Tracking automático de created_at y updated_at

## Migración desde SharedPreferences

Una vez configurado Supabase, los datos se guardarán en la nube automáticamente.

Para migrar datos existentes de SharedPreferences:

1. Los nuevos datos se guardarán en Supabase
2. Los datos antiguos quedarán en SharedPreferences como backup
3. Podrás exportar/importar datos manualmente si es necesario

## Troubleshooting

### Error: "Invalid API key"
- Verifica que copiaste correctamente el Anon Key
- Asegúrate de no tener espacios extra

### Error: "Failed to fetch"
- Verifica que el Project URL sea correcto
- Asegúrate de tener internet

### Error: "Row Level Security"
- Verifica que las políticas RLS se crearon correctamente
- Ve a SQL Editor y ejecuta el script nuevamente

### Los datos no aparecen
- Verifica que el usuario esté autenticado
- Revisa la consola de Supabase para ver los datos reales
- Verifica que el user_id coincida con auth.uid()

## Recursos Adicionales

- 📚 Documentación Supabase Flutter: https://supabase.com/docs/guides/getting-started/tutorials/with-flutter
- 🎥 Video Tutorial: https://www.youtube.com/watch?v=F8M4OXPtABI
- 💬 Soporte: https://supabase.com/support

## Próximos Pasos

1. ✅ Configurar credenciales
2. ✅ Crear tablas en Supabase
3. ⏳ Implementar login/registro
4. ⏳ Migrar servicios a Supabase
5. ⏳ Probar sincronización de datos
6. ⏳ Implementar modo offline (opcional)
