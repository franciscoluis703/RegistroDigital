-- ============================================================================
-- FIX: Agregar columnas faltantes a datos_centro_educativo
-- ============================================================================

-- Agregar todas las columnas que faltan
DO $$
BEGIN
    ALTER TABLE public.datos_centro_educativo ADD COLUMN IF NOT EXISTS correo TEXT;
    ALTER TABLE public.datos_centro_educativo ADD COLUMN IF NOT EXISTS telefono_centro TEXT;
    ALTER TABLE public.datos_centro_educativo ADD COLUMN IF NOT EXISTS codigo_gestion TEXT;
    ALTER TABLE public.datos_centro_educativo ADD COLUMN IF NOT EXISTS codigo_cartografia TEXT;
    ALTER TABLE public.datos_centro_educativo ADD COLUMN IF NOT EXISTS director_nombre TEXT;
    ALTER TABLE public.datos_centro_educativo ADD COLUMN IF NOT EXISTS director_correo TEXT;
    ALTER TABLE public.datos_centro_educativo ADD COLUMN IF NOT EXISTS director_telefono TEXT;
    ALTER TABLE public.datos_centro_educativo ADD COLUMN IF NOT EXISTS docente_nombre TEXT;
    ALTER TABLE public.datos_centro_educativo ADD COLUMN IF NOT EXISTS docente_correo TEXT;
    ALTER TABLE public.datos_centro_educativo ADD COLUMN IF NOT EXISTS docente_telefono TEXT;
    ALTER TABLE public.datos_centro_educativo ADD COLUMN IF NOT EXISTS sector TEXT;
    ALTER TABLE public.datos_centro_educativo ADD COLUMN IF NOT EXISTS zona TEXT;
    ALTER TABLE public.datos_centro_educativo ADD COLUMN IF NOT EXISTS jornada TEXT;
END $$;

-- ============================================================================
-- FIN - Ahora la tabla tiene todas las columnas necesarias
-- ============================================================================
