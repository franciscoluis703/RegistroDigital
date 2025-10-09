# 🔧 INSTRUCCIONES PARA REPARAR LA PERSISTENCIA DE ASISTENCIA

## Problema Detectado

La pantalla de asistencia muestra "Todos los cambios se guardan automáticamente" pero los datos **NO se están guardando permanentemente en Supabase**.

## Causa del Problema

Las tablas de asistencia (`asistencia_registros_meses` y `asistencia_datos_mes`) probablemente no existen en Supabase, o el schema cache está desactualizado.

## Solución Paso a Paso

### 1️⃣ Verificar qué tablas existen actualmente

1. Ve a **Supabase Dashboard** → https://app.supabase.com
2. Selecciona tu proyecto
3. Ve a **SQL Editor** (menú izquierdo)
4. Copia y pega todo el contenido del archivo: `database/VERIFICAR_TABLAS_EXISTENTES.sql`
5. Haz clic en **RUN**
6. Revisa los resultados:
   - La primera consulta muestra **todas las tablas que existen**
   - La segunda consulta muestra **las tablas que faltan**
   - La tercera consulta muestra **las columnas de las tablas de asistencia**

### 2️⃣ Crear/Reparar las tablas de asistencia

1. En **SQL Editor**, abre un nuevo query
2. Copia y pega todo el contenido del archivo: `database/VERIFY_AND_FIX_ASISTENCIA.sql`
3. Haz clic en **RUN**
4. Deberías ver el mensaje: "Success. No rows returned"

### 3️⃣ Refrescar el Schema Cache de Supabase (MUY IMPORTANTE)

Este paso es **CRÍTICO** para que los cambios tomen efecto:

1. Ve a **Settings** (menú izquierdo)
2. Haz clic en **API**
3. Busca la sección **"Schema Cache"**
4. Haz clic en el botón **"Refresh Schema Cache"** o **"Reload Schema"**
5. Espera unos segundos hasta que aparezca el mensaje de confirmación

### 4️⃣ Verificar que las tablas aparecen en Table Editor

1. Ve a **Table Editor** (menú izquierdo)
2. Deberías ver estas dos tablas:
   - ✅ `asistencia_registros_meses`
   - ✅ `asistencia_datos_mes`
3. Haz clic en cada tabla para verificar que tienen las columnas correctas:
   - `id` (UUID)
   - `user_id` (UUID)
   - `curso` (TEXT)
   - `seccion` (TEXT)
   - `mes` (TEXT) - solo en `asistencia_datos_mes`
   - `datos` (JSONB)
   - `created_at` (TIMESTAMP)
   - `updated_at` (TIMESTAMP)

### 5️⃣ Reiniciar la aplicación Flutter

1. En la terminal donde está corriendo la app, presiona `q` para cerrar la app
2. Ejecuta nuevamente:
   ```bash
   flutter run -d linux
   ```

### 6️⃣ Probar que funciona

1. Abre la pantalla de **Asistencia**
2. Marca asistencia para algunos estudiantes
3. Marca algunos días como feriados
4. **Cierra completamente la aplicación** (presiona `q` en la terminal)
5. Vuelve a ejecutar `flutter run -d linux`
6. Abre la pantalla de **Asistencia** nuevamente
7. **Verifica que los datos que marcaste antes siguen ahí** ✅

## ¿Qué hace el código de asistencia?

El servicio `asistencia_supabase_service.dart` tiene dos métodos principales:

1. **`guardarDatosAsistenciaMes()`** (líneas 381-440):
   - Guarda la matriz de asistencia completa en formato JSONB
   - Incluye: asistencia, feriados, días del mes, última actualización
   - Usa `UPSERT` para crear o actualizar automáticamente

2. **`obtenerDatosAsistenciaMes()`** (líneas 443-483):
   - Carga los datos guardados desde Supabase
   - Deserializa el JSONB a la estructura que usa la app
   - Filtra por: user_id, curso, sección y mes

## Estructura de datos guardada

```json
{
  "asistencia": [
    ["P", "A", "T", ...],  // Fila por estudiante
    ["P", "P", "P", ...],  // P=Presente, A=Ausente, T=Tardanza
    ...
  ],
  "feriados": {
    "1": "Año Nuevo",
    "15": "Día de la Constitución"
  },
  "diasMes": ["1", "2", "3", ..., "31"],
  "ultimaActualizacion": "2025-10-08T10:30:00.000Z"
}
```

## Solución de problemas

### Si aún no guarda después de seguir todos los pasos:

1. Revisa los logs de la aplicación en la terminal
2. Busca errores que contengan:
   - `PostgrestException`
   - `asistencia_datos_mes`
   - `PGRST`
3. Verifica que estás **autenticado** (iniciaste sesión en la app)
4. Ve a Supabase → Table Editor → `asistencia_datos_mes`
5. Verifica manualmente si hay filas creadas

### Si ves el error "table not found":

1. Repite el paso **3️⃣** (Refresh Schema Cache)
2. Espera 30 segundos
3. Reinicia la app

### Si ves el error "permission denied" o "policy violation":

1. Ve a Supabase → Authentication
2. Verifica que tu usuario está autenticado
3. Copia el UUID de tu usuario
4. Ve a Table Editor → `asistencia_datos_mes`
5. Verifica que las políticas RLS están habilitadas

## Contacto

Si después de seguir todos estos pasos el problema persiste, revisa:
- Los logs completos de la aplicación
- La pestaña de Network en el dashboard de Supabase
- Los logs de Supabase (Logs > API Logs)
