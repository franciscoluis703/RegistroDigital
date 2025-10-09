# Bloc de Notas - Configuración

## Descripción
El Bloc de Notas permite a los usuarios crear, editar y eliminar apuntes personales desde la aplicación.

## Características

- ✅ **Crear notas**: Agregar nuevas notas con título y contenido
- ✅ **Editar notas**: Modificar notas existentes
- ✅ **Eliminar notas**: Borrar notas que ya no necesites
- ✅ **Búsqueda**: Buscar notas por título o contenido
- ✅ **Sincronización automática**: Todas las notas se guardan en Supabase
- ✅ **Seguridad**: Cada usuario solo puede ver sus propias notas (RLS activado)

## Instalación en Supabase

1. Accede al panel de Supabase: https://app.supabase.com
2. Selecciona tu proyecto
3. Ve a la sección "SQL Editor"
4. Copia y pega el contenido del archivo `create_notas_table.sql`
5. Ejecuta el script haciendo clic en "Run"

## Estructura de la tabla

La tabla `notas` almacena:
- `id`: UUID único de la nota
- `user_id`: ID del usuario (referencia a auth.users)
- `titulo`: Título de la nota (obligatorio)
- `contenido`: Contenido de la nota (opcional)
- `created_at`: Fecha de creación
- `updated_at`: Fecha de última actualización (se actualiza automáticamente)

## Características técnicas

### Seguridad (RLS)
- Cada usuario solo puede ver, crear, editar y eliminar sus propias notas
- Las políticas de seguridad están configuradas a nivel de base de datos

### Búsqueda
- Índice de búsqueda de texto completo en español
- Permite buscar en título y contenido simultáneamente

### Actualización automática
- El campo `updated_at` se actualiza automáticamente mediante un trigger
- No es necesario actualizar manualmente este campo desde la aplicación

## Uso en la aplicación

1. **Acceder al Bloc de Notas**:
   - Desde la pantalla principal, toca el botón "Bloc de Notas"

2. **Crear una nota**:
   - Toca el botón flotante "Nueva Nota"
   - Escribe un título (obligatorio)
   - Escribe el contenido (opcional)
   - Toca el botón ✓ para guardar

3. **Editar una nota**:
   - Toca la nota que deseas editar
   - Modifica el título o contenido
   - Toca el botón ✓ para guardar

4. **Eliminar una nota**:
   - Toca el icono de basura en la nota que deseas eliminar
   - Confirma la eliminación

## Personalización

Las notas se muestran con diferentes colores para facilitar su identificación visual:
- Púrpura
- Azul
- Verde
- Naranja
- Rosa
- Turquesa

Los colores se asignan automáticamente según la posición de la nota en la lista.
