# Sistema de Seguridad y Aislamiento de Datos

## Resumen

Este sistema implementa un **aislamiento completo de datos por usuario** utilizando Row Level Security (RLS) de Supabase. Cada usuario solo puede acceder, modificar y eliminar sus propios datos, garantizando la privacidad y seguridad de la información.

## Arquitectura de Seguridad

### 1. Autenticación (Auth)

- **Proveedor**: Supabase Auth
- **Flujo**: Email y contraseña
- **Metadata**: Al registrarse, se guarda el nombre del usuario en `raw_user_meta_data->>'nombre'`

### 2. Políticas RLS (Row Level Security)

Todas las tablas tienen habilitado RLS y políticas específicas:

#### Tabla: `perfiles`
```sql
-- Los usuarios solo pueden ver y gestionar su propio perfil
CREATE POLICY "Usuarios gestionan su perfil"
ON perfiles FOR ALL
USING (auth.uid() = id);
```

#### Tabla: `cursos`
```sql
-- Los usuarios solo pueden ver y gestionar sus propios cursos
CREATE POLICY "Usuarios gestionan sus cursos"
ON cursos FOR ALL
USING (auth.uid() = user_id);
```

#### Tabla: `estudiantes`
```sql
-- Los usuarios solo pueden ver estudiantes de sus propios cursos
CREATE POLICY "Usuarios gestionan estudiantes de sus cursos"
ON estudiantes FOR ALL
USING (EXISTS (
  SELECT 1 FROM cursos
  WHERE cursos.id = estudiantes.curso_id
  AND cursos.user_id = auth.uid()
));
```

#### Tabla: `asistencias`
```sql
-- Los usuarios solo pueden ver asistencias de sus propios cursos
CREATE POLICY "Usuarios gestionan asistencias de sus cursos"
ON asistencias FOR ALL
USING (EXISTS (
  SELECT 1 FROM cursos
  WHERE cursos.id = asistencias.curso_id
  AND cursos.user_id = auth.uid()
));
```

#### Tabla: `calificaciones`
```sql
-- Los usuarios solo pueden ver calificaciones de sus propios cursos
CREATE POLICY "Usuarios gestionan calificaciones de sus cursos"
ON calificaciones FOR ALL
USING (EXISTS (
  SELECT 1 FROM cursos
  WHERE cursos.id = calificaciones.curso_id
  AND cursos.user_id = auth.uid()
));
```

#### Tabla: `promocion_grado`
```sql
-- Los usuarios solo pueden ver promociones de sus propios cursos
CREATE POLICY "Usuarios gestionan promoción de sus cursos"
ON promocion_grado FOR ALL
USING (EXISTS (
  SELECT 1 FROM cursos
  WHERE cursos.id = promocion_grado.curso_id
  AND cursos.user_id = auth.uid()
));
```

#### Tabla: `horarios`
```sql
-- Los usuarios solo pueden ver sus propios horarios
CREATE POLICY "Usuarios gestionan sus horarios"
ON horarios FOR ALL
USING (auth.uid() = user_id);
```

#### Tabla: `eventos_calendario`
```sql
-- Los usuarios solo pueden ver sus propios eventos
CREATE POLICY "Usuarios gestionan sus eventos"
ON eventos_calendario FOR ALL
USING (auth.uid() = user_id);
```

### 3. Creación Automática de Perfil

Cuando un usuario se registra, se ejecuta automáticamente un trigger que crea su perfil:

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.perfiles (id, nombre, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'nombre', 'Usuario'),
    NEW.email
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

## Implementación en el Código

### Servicios de Supabase

Todos los servicios verifican el `user_id` automáticamente:

#### CursosSupabaseService
```dart
Future<List<Map<String, dynamic>>> obtenerCursos() async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];

  final response = await supabase
      .from('cursos')
      .select()
      .eq('user_id', userId)  // Filtro por usuario
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
}
```

#### EstudiantesSupabaseService
```dart
Future<List<Map<String, dynamic>>> obtenerEstudiantes(String cursoId) async {
  // RLS se encarga automáticamente de verificar que el curso pertenezca al usuario
  final response = await supabase
      .from('estudiantes')
      .select()
      .eq('curso_id', cursoId)
      .order('numero_orden', ascending: true);

  return List<Map<String, dynamic>>.from(response);
}
```

### Flujo de Registro

1. **Usuario completa formulario** (`sign_up_view.dart`)
2. **Se crea cuenta en Supabase Auth** con metadata `{nombre: "Nombre Usuario"}`
3. **Trigger automático** crea registro en tabla `perfiles`
4. **Usuario recibe email** de confirmación
5. **Al confirmar email** puede iniciar sesión

### Flujo de Autenticación

1. **Usuario ingresa credenciales** (`sign_in_view.dart`)
2. **Supabase valida** y retorna sesión con JWT
3. **JWT contiene** `auth.uid()` usado en todas las políticas RLS
4. **Todas las consultas** automáticamente filtran por `user_id`

## Garantías de Seguridad

✅ **Aislamiento Total**: Los datos de un usuario son completamente invisibles para otros usuarios

✅ **Nivel de Base de Datos**: La seguridad se implementa en la base de datos, no solo en el cliente

✅ **Prevención de Manipulación**: Aunque alguien intente modificar el código del cliente, RLS lo previene a nivel de base de datos

✅ **Cascada de Eliminación**: Si se elimina un curso, todos sus estudiantes, asistencias y calificaciones se eliminan automáticamente

✅ **Verificación de Propiedad**: Las tablas dependientes verifican la propiedad a través de relaciones (`EXISTS`)

## Pruebas de Seguridad

### Escenarios a Probar

1. **Usuario A crea curso** → Solo Usuario A puede verlo
2. **Usuario B crea curso** → Usuario A no puede verlo ni modificarlo
3. **Usuario A agrega estudiante** → Solo visible para Usuario A
4. **Usuario B intenta acceder a estudiante de A** → Denegado por RLS
5. **Usuario elimina su cuenta** → Todos sus datos se eliminan automáticamente (CASCADE)

### Comandos de Verificación SQL

```sql
-- Ver políticas RLS de una tabla
SELECT * FROM pg_policies WHERE tablename = 'cursos';

-- Verificar que RLS está habilitado
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND rowsecurity = true;
```

## Mejores Prácticas

1. **Nunca deshabilitar RLS** en producción
2. **Verificar user_id** en todos los servicios del cliente
3. **No confiar solo** en validaciones del cliente
4. **Usar CASCADE** para mantener integridad referencial
5. **Logs de auditoría** para operaciones críticas (opcional)

## Recuperación de Contraseña

El sistema incluye recuperación segura de contraseña:

1. Usuario solicita reset desde `/forgot-password`
2. Supabase envía email con token único
3. Usuario hace clic en enlace y define nueva contraseña
4. Token expira después de 1 hora (configurable)

## Configuración Adicional Recomendada

### En Supabase Dashboard

1. **Email Templates**: Personalizar emails de confirmación y recuperación
2. **Rate Limiting**: Limitar intentos de login
3. **Password Policies**: Requerir contraseñas fuertes
4. **MFA (Multi-Factor Auth)**: Opcional para mayor seguridad
5. **Storage Policies**: Configurar RLS para archivos (fotos de perfil)

## Soporte y Mantenimiento

- **Documentación**: Mantener este archivo actualizado
- **Migraciones**: Usar archivos SQL versionados
- **Testing**: Probar RLS después de cada cambio de esquema
- **Monitoreo**: Revisar logs de Supabase regularmente

---

**Última actualización**: 2025-10-05
**Versión**: 1.0
**Responsable**: Sistema de Registro Docente
