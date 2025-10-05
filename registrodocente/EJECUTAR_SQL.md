# 📝 Cómo Ejecutar el SQL en Supabase

## ⚡ Pasos Rápidos (5 minutos)

### 1. Ir al SQL Editor

1. Abre tu navegador y ve a: https://supabase.com/dashboard/project/fqghquowfozmmbohzebb

2. En la barra lateral izquierda, busca y haz click en **SQL Editor** (icono </>)

### 2. Abrir el archivo SQL

1. En tu computadora, abre el archivo: `supabase_schema.sql`

2. Selecciona TODO el contenido (Ctrl/Cmd + A)

3. Copia todo (Ctrl/Cmd + C)

### 3. Ejecutar en Supabase

1. En Supabase SQL Editor, haz click en **New Query** (botón verde arriba)

2. Pega el contenido copiado (Ctrl/Cmd + V)

3. Haz click en **Run** (o presiona Ctrl/Cmd + Enter)

4. Espera unos segundos...

5. ✅ Deberías ver: **"Success. No rows returned"** (esto es NORMAL y correcto)

### 4. Verificar que funcionó

1. En la barra lateral izquierda, haz click en **Table Editor** (icono de tabla)

2. Deberías ver estas 8 tablas creadas:
   - ✅ asistencias
   - ✅ calificaciones
   - ✅ cursos
   - ✅ datos_emergencia
   - ✅ docentes
   - ✅ estudiantes
   - ✅ evaluaciones
   - ✅ parentesco

3. Haz click en cualquier tabla (ej: `cursos`)

4. Verifica que tenga un **candado verde** 🔒 que diga "RLS enabled"

## ✅ ¡Listo!

Si ves las 8 tablas y tienen RLS habilitado, ¡todo está perfecto!

Ahora puedes:
1. Ejecutar la app: `flutter run`
2. Los datos se guardarán automáticamente en Supabase
3. Cada usuario tendrá sus propios datos separados

## ❌ Si algo salió mal

### Error: "permission denied for schema public"
**Solución**: Tu usuario no tiene permisos. Verifica que estés usando el proyecto correcto.

### Error: "relation already exists"
**Solución**: Las tablas ya existen. No necesitas ejecutar el SQL de nuevo.

### No veo las tablas
**Solución**:
1. Refresca la página (F5)
2. Verifica que el SQL se ejecutó sin errores
3. Intenta ejecutar el SQL de nuevo

### Veo las tablas pero no tienen candado verde
**Solución**: El RLS no se habilitó. Ejecuta este SQL:
```sql
ALTER TABLE docentes ENABLE ROW LEVEL SECURITY;
ALTER TABLE cursos ENABLE ROW LEVEL SECURITY;
ALTER TABLE estudiantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE asistencias ENABLE ROW LEVEL SECURITY;
ALTER TABLE calificaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE evaluaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE datos_emergencia ENABLE ROW LEVEL SECURITY;
ALTER TABLE parentesco ENABLE ROW LEVEL SECURITY;
```

## 📹 Video Tutorial

Si prefieres ver un video de cómo hacerlo:
https://youtu.be/dU7GwCOgvNY?t=180

## 🆘 Necesitas ayuda?

Si tienes algún problema, toma una captura de pantalla del error y muéstramela.
