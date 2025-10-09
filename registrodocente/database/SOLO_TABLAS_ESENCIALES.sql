-- ============================================================================
-- SCRIPT SIMPLIFICADO: SOLO TABLAS ESENCIALES
-- ============================================================================
-- Este script crea SOLO las tablas esenciales que están causando errores
-- ============================================================================

-- ============================================================================
-- 1. TABLA: notas (Elimina el error PostgrestException)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.notas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    titulo TEXT NOT NULL,
    contenido TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_notas_user_id ON public.notas(user_id);
ALTER TABLE public.notas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Los usuarios pueden ver sus propias notas" ON public.notas;
DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propias notas" ON public.notas;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propias notas" ON public.notas;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propias notas" ON public.notas;

CREATE POLICY "Los usuarios pueden ver sus propias notas" ON public.notas FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden insertar sus propias notas" ON public.notas FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden actualizar sus propias notas" ON public.notas FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden eliminar sus propias notas" ON public.notas FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- 2. TABLA: asistencia_datos_mes (Para guardar asistencia)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.asistencia_datos_mes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    mes TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, curso, seccion, mes)
);

CREATE INDEX IF NOT EXISTS idx_asistencia_datos_mes_user_id ON public.asistencia_datos_mes(user_id);
ALTER TABLE public.asistencia_datos_mes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios datos de asistencia" ON public.asistencia_datos_mes;
DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propios datos de asistencia" ON public.asistencia_datos_mes;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propios datos de asistencia" ON public.asistencia_datos_mes;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propios datos de asistencia" ON public.asistencia_datos_mes;

CREATE POLICY "Los usuarios pueden ver sus propios datos de asistencia" ON public.asistencia_datos_mes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden insertar sus propios datos de asistencia" ON public.asistencia_datos_mes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden actualizar sus propios datos de asistencia" ON public.asistencia_datos_mes FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden eliminar sus propios datos de asistencia" ON public.asistencia_datos_mes FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- 3. TABLA: asistencia_registros_meses (Para guardar lista de meses)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.asistencia_registros_meses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, curso, seccion)
);

CREATE INDEX IF NOT EXISTS idx_asistencia_registros_meses_user_id ON public.asistencia_registros_meses(user_id);
ALTER TABLE public.asistencia_registros_meses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios registros de meses" ON public.asistencia_registros_meses;
DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propios registros de meses" ON public.asistencia_registros_meses;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propios registros de meses" ON public.asistencia_registros_meses;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propios registros de meses" ON public.asistencia_registros_meses;

CREATE POLICY "Los usuarios pueden ver sus propios registros de meses" ON public.asistencia_registros_meses FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden insertar sus propios registros de meses" ON public.asistencia_registros_meses FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden actualizar sus propios registros de meses" ON public.asistencia_registros_meses FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden eliminar sus propios registros de meses" ON public.asistencia_registros_meses FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- 4. TABLA: nombres_grupos_calificaciones
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.nombres_grupos_calificaciones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    nombres JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, curso, seccion)
);

CREATE INDEX IF NOT EXISTS idx_nombres_grupos_user_id ON public.nombres_grupos_calificaciones(user_id);
ALTER TABLE public.nombres_grupos_calificaciones ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios nombres de grupos" ON public.nombres_grupos_calificaciones;
DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propios nombres de grupos" ON public.nombres_grupos_calificaciones;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propios nombres de grupos" ON public.nombres_grupos_calificaciones;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propios nombres de grupos" ON public.nombres_grupos_calificaciones;

CREATE POLICY "Los usuarios pueden ver sus propios nombres de grupos" ON public.nombres_grupos_calificaciones FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden insertar sus propios nombres de grupos" ON public.nombres_grupos_calificaciones FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden actualizar sus propios nombres de grupos" ON public.nombres_grupos_calificaciones FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden eliminar sus propios nombres de grupos" ON public.nombres_grupos_calificaciones FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- FIN - Ahora ejecuta: Settings → API → Refresh Schema Cache
-- ============================================================================
