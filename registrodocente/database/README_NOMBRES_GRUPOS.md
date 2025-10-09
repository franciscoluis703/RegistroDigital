# Configuración de Nombres de Grupos de Calificaciones

## Descripción
Este módulo permite a los usuarios personalizar los nombres de los 4 grupos de calificaciones (competencias) en la pantalla de calificaciones.

## Instalación en Supabase

1. Accede al panel de Supabase: https://app.supabase.com
2. Selecciona tu proyecto
3. Ve a la sección "SQL Editor"
4. Copia y pega el contenido del archivo `create_nombres_grupos_calificaciones_table.sql`
5. Ejecuta el script haciendo clic en "Run"

## Estructura de la tabla

La tabla `nombres_grupos_calificaciones` almacena:
- `id`: UUID único del registro
- `user_id`: ID del usuario (referencia a auth.users)
- `curso`: Nombre del curso (ej: "LENGUA ESPAÑOLA")
- `seccion`: Sección del curso (ej: "A")
- `nombres`: Objeto JSONB con la estructura:
  ```json
  {
    "grupo1": "Competencia Comunicativa",
    "grupo2": "Pensamiento Lógico",
    "grupo3": "Ética y Ciudadana",
    "grupo4": "Desarrollo Personal",
    "ultimaActualizacion": "2025-10-08T10:30:00Z"
  }
  ```
- `created_at`: Fecha de creación
- `updated_at`: Fecha de última actualización

## Uso en la aplicación

Los usuarios pueden editar los nombres de los grupos haciendo clic en el icono de editar que aparece junto a cada grupo en la pantalla de calificaciones.

Los cambios se guardan automáticamente en Supabase y persisten entre sesiones.

## Valores por defecto

Si no se han personalizado los nombres, la aplicación mostrará:
- Grupo 1: "GRUPO 1:"
- Grupo 2: "GRUPO 2:"
- Grupo 3: "GRUPO 3"
- Grupo 4: "GRUPO 4"
