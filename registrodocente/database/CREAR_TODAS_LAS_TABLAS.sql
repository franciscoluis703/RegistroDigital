-- ============================================================================
-- SCRIPT DEFINITIVO: CREAR TODAS LAS TABLAS NECESARIAS EN SUPABASE
-- ============================================================================
-- Este script crea TODAS las tablas que tu aplicación necesita
-- Ejecuta este script COMPLETO en el SQL Editor de Supabase
-- ============================================================================

-- ============================================================================
-- 1. TABLA: notas (Bloc de notas)
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
CREATE INDEX IF NOT EXISTS idx_notas_updated_at ON public.notas(updated_at DESC);

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
-- 2. TABLA: nombres_grupos_calificaciones
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
CREATE INDEX IF NOT EXISTS idx_nombres_grupos_curso_seccion ON public.nombres_grupos_calificaciones(curso, seccion);

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
-- 3. TABLA: asistencia_registros_meses
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
CREATE INDEX IF NOT EXISTS idx_asistencia_registros_meses_curso_seccion ON public.asistencia_registros_meses(curso, seccion);

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
-- 4. TABLA: asistencia_datos_mes
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
CREATE INDEX IF NOT EXISTS idx_asistencia_datos_mes_curso_seccion_mes ON public.asistencia_datos_mes(curso, seccion, mes);

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
-- 5. TABLA: calificaciones_notas_grupos
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.calificaciones_notas_grupos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, curso, seccion)
);

CREATE INDEX IF NOT EXISTS idx_calificaciones_notas_user_id ON public.calificaciones_notas_grupos(user_id);
CREATE INDEX IF NOT EXISTS idx_calificaciones_notas_curso_seccion ON public.calificaciones_notas_grupos(curso, seccion);

ALTER TABLE public.calificaciones_notas_grupos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Los usuarios pueden ver sus propias calificaciones" ON public.calificaciones_notas_grupos;
DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propias calificaciones" ON public.calificaciones_notas_grupos;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propias calificaciones" ON public.calificaciones_notas_grupos;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propias calificaciones" ON public.calificaciones_notas_grupos;

CREATE POLICY "Los usuarios pueden ver sus propias calificaciones" ON public.calificaciones_notas_grupos FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden insertar sus propias calificaciones" ON public.calificaciones_notas_grupos FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden actualizar sus propias calificaciones" ON public.calificaciones_notas_grupos FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden eliminar sus propias calificaciones" ON public.calificaciones_notas_grupos FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- 6. TABLA: datos_centro_educativo
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.datos_centro_educativo (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, curso, seccion)
);

-- Agregar columnas faltantes si no existen
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

CREATE INDEX IF NOT EXISTS idx_datos_centro_user_id ON public.datos_centro_educativo(user_id);
CREATE INDEX IF NOT EXISTS idx_datos_centro_curso_seccion ON public.datos_centro_educativo(curso, seccion);

ALTER TABLE public.datos_centro_educativo ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios datos de centro" ON public.datos_centro_educativo;
DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propios datos de centro" ON public.datos_centro_educativo;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propios datos de centro" ON public.datos_centro_educativo;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propios datos de centro" ON public.datos_centro_educativo;

CREATE POLICY "Los usuarios pueden ver sus propios datos de centro" ON public.datos_centro_educativo FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden insertar sus propios datos de centro" ON public.datos_centro_educativo FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden actualizar sus propios datos de centro" ON public.datos_centro_educativo FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden eliminar sus propios datos de centro" ON public.datos_centro_educativo FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- 7. TABLA: promocion_grado_datos
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.promocion_grado_datos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, curso, seccion)
);

CREATE INDEX IF NOT EXISTS idx_promocion_grado_user_id ON public.promocion_grado_datos(user_id);
CREATE INDEX IF NOT EXISTS idx_promocion_grado_curso_seccion ON public.promocion_grado_datos(curso, seccion);

ALTER TABLE public.promocion_grado_datos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios datos de promoción" ON public.promocion_grado_datos;
DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propios datos de promoción" ON public.promocion_grado_datos;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propios datos de promoción" ON public.promocion_grado_datos;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propios datos de promoción" ON public.promocion_grado_datos;

CREATE POLICY "Los usuarios pueden ver sus propios datos de promoción" ON public.promocion_grado_datos FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden insertar sus propios datos de promoción" ON public.promocion_grado_datos FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden actualizar sus propios datos de promoción" ON public.promocion_grado_datos FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden eliminar sus propios datos de promoción" ON public.promocion_grado_datos FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- 8. TABLA: evaluaciones_dias
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.evaluaciones_dias (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, curso, seccion)
);

CREATE INDEX IF NOT EXISTS idx_evaluaciones_dias_user_id ON public.evaluaciones_dias(user_id);
CREATE INDEX IF NOT EXISTS idx_evaluaciones_dias_curso_seccion ON public.evaluaciones_dias(curso, seccion);

ALTER TABLE public.evaluaciones_dias ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Los usuarios pueden ver sus propias evaluaciones" ON public.evaluaciones_dias;
DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propias evaluaciones" ON public.evaluaciones_dias;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propias evaluaciones" ON public.evaluaciones_dias;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propias evaluaciones" ON public.evaluaciones_dias;

CREATE POLICY "Los usuarios pueden ver sus propias evaluaciones" ON public.evaluaciones_dias FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden insertar sus propias evaluaciones" ON public.evaluaciones_dias FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden actualizar sus propias evaluaciones" ON public.evaluaciones_dias FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden eliminar sus propias evaluaciones" ON public.evaluaciones_dias FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- 9. TABLA: configuraciones_horario
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.configuraciones_horario (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, curso, seccion)
);

CREATE INDEX IF NOT EXISTS idx_configuraciones_horario_user_id ON public.configuraciones_horario(user_id);
CREATE INDEX IF NOT EXISTS idx_configuraciones_horario_curso_seccion ON public.configuraciones_horario(curso, seccion);

ALTER TABLE public.configuraciones_horario ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Los usuarios pueden ver sus propias configuraciones de horario" ON public.configuraciones_horario;
DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propias configuraciones de horario" ON public.configuraciones_horario;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propias configuraciones de horario" ON public.configuraciones_horario;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propias configuraciones de horario" ON public.configuraciones_horario;

CREATE POLICY "Los usuarios pueden ver sus propias configuraciones de horario" ON public.configuraciones_horario FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden insertar sus propias configuraciones de horario" ON public.configuraciones_horario FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden actualizar sus propias configuraciones de horario" ON public.configuraciones_horario FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden eliminar sus propias configuraciones de horario" ON public.configuraciones_horario FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- 10. TABLA: eventos_calendario
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.eventos_calendario (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    titulo TEXT NOT NULL,
    descripcion TEXT,
    fecha DATE NOT NULL,
    hora TIME,
    tipo TEXT NOT NULL,
    curso TEXT,
    seccion TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_eventos_calendario_user_id ON public.eventos_calendario(user_id);
CREATE INDEX IF NOT EXISTS idx_eventos_calendario_fecha ON public.eventos_calendario(fecha);
CREATE INDEX IF NOT EXISTS idx_eventos_calendario_tipo ON public.eventos_calendario(tipo);

ALTER TABLE public.eventos_calendario ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios eventos" ON public.eventos_calendario;
DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propios eventos" ON public.eventos_calendario;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propios eventos" ON public.eventos_calendario;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propios eventos" ON public.eventos_calendario;

CREATE POLICY "Los usuarios pueden ver sus propios eventos" ON public.eventos_calendario FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden insertar sus propios eventos" ON public.eventos_calendario FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden actualizar sus propios eventos" ON public.eventos_calendario FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Los usuarios pueden eliminar sus propios eventos" ON public.eventos_calendario FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
-- SIGUIENTE PASO MUY IMPORTANTE:
-- 1. Ve a Settings → API → Refresh Schema Cache
-- 2. Espera 30 segundos
-- 3. Reinicia tu aplicación Flutter
-- ============================================================================
