# Configuración de Supabase Storage para Fotos de Perfil

Este documento explica cómo configurar Supabase Storage para permitir que los usuarios suban fotos de perfil.

## Paso 1: Ejecutar el Script SQL

1. Ve a tu proyecto de Supabase: https://supabase.com/dashboard
2. Navega a **SQL Editor** en el menú lateral
3. Crea una nueva query
4. Copia y pega el contenido del archivo: `database/create_avatars_bucket.sql`
5. Ejecuta la query

## Paso 2: Verificar la Configuración

### Verificar el Bucket

1. Ve a **Storage** en el menú lateral de Supabase
2. Deberías ver un bucket llamado `avatars`
3. Verifica que esté marcado como **Public**

### Verificar las Políticas

1. En el bucket `avatars`, haz clic en **Policies**
2. Deberías ver las siguientes políticas:
   - ✅ Public Access (SELECT)
   - ✅ Authenticated users can upload their own avatars (INSERT)
   - ✅ Authenticated users can update their own avatars (UPDATE)
   - ✅ Authenticated users can delete their own avatars (DELETE)

## Paso 3: Probar la Funcionalidad

### En Plataformas Soportadas (Android, iOS, macOS, Windows, Web)

1. Abre la aplicación
2. Ve a **Mi Perfil**
3. Toca el ícono de cámara en la foto de perfil
4. Selecciona una opción:
   - **Tomar foto**: Captura una foto con la cámara
   - **Seleccionar de galería**: Elige una imagen de tu galería
   - **Usar URL de imagen**: Ingresa una URL directa

### En Linux

**Nota**: En Linux, la selección de archivos nativos no está soportada por Flutter ImagePicker.

1. Abre la aplicación
2. Ve a **Mi Perfil**
3. Toca el ícono de cámara en la foto de perfil
4. Usa la opción **"Usar URL de imagen"**
5. Puedes usar:
   - Una URL de tu propia imagen
   - Avatares de https://i.pravatar.cc/150?img=X (X = 1-70)
   - Avatares generados: https://ui-avatars.com/api/?name=Tu+Nombre

## Estructura del Bucket

```
avatars/
└── profile_pictures/
    ├── perfil_uuid1.jpg
    ├── perfil_uuid2.png
    └── perfil_uuid3.jpg
```

## Límites Configurados

- **Tamaño máximo**: 5 MB por archivo
- **Tipos de archivo permitidos**:
  - image/jpeg
  - image/jpg
  - image/png
  - image/gif
  - image/webp

## Solución de Problemas

### Error: "Bucket not found"

**Solución**: Ejecuta el script SQL `database/create_avatars_bucket.sql`

### Error: "Permission denied"

**Solución**: Verifica que las políticas de seguridad estén correctamente configuradas

### Error en Linux: "ImagePicker not supported"

**Solución**: Esto es normal. Usa la opción "URL de imagen" en su lugar

### Las imágenes no se cargan

**Solución**:
1. Verifica que el bucket sea público
2. Revisa las políticas RLS (Row Level Security)
3. Verifica que estés autenticado en la aplicación

## URLs de Ejemplo para Pruebas

```
https://i.pravatar.cc/150?img=3
https://i.pravatar.cc/150?img=12
https://ui-avatars.com/api/?name=John+Doe&background=0D8ABC&color=fff
https://avatars.githubusercontent.com/u/1?v=4
```

## Servicios de Storage

La aplicación usa automáticamente:
- **Firebase Storage**: En Android, iOS, macOS, Windows y Web
- **Supabase Storage**: En Linux o como fallback

El servicio se selecciona automáticamente según la plataforma.
