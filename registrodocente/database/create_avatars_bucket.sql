-- Crear bucket 'avatars' para almacenar fotos de perfil
-- Este script crea el bucket y configura las políticas de seguridad necesarias

-- Crear el bucket si no existe
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true,  -- Público para que las URLs sean accesibles
  5242880,  -- 5MB de límite
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Política: Permitir a todos ver las imágenes (bucket público)
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

-- Política: Permitir a usuarios autenticados subir sus propias imágenes
CREATE POLICY "Authenticated users can upload their own avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = 'profile_pictures'
);

-- Política: Permitir a usuarios autenticados actualizar sus propias imágenes
CREATE POLICY "Authenticated users can update their own avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = 'profile_pictures'
);

-- Política: Permitir a usuarios autenticados eliminar sus propias imágenes
CREATE POLICY "Authenticated users can delete their own avatars"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = 'profile_pictures'
);
