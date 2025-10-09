-- ============================================================================
-- SETUP FINAL DE BASE DE DATOS SUPABASE (CON ALTER TABLE)
-- Registro Docente - Agrega columnas y tablas faltantes
-- ============================================================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. TABLA: perfiles
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.perfiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    nombre TEXT,
    email TEXT,
    foto_perfil TEXT,
    genero TEXT,
    centro_educativo TEXT,
    regional TEXT,
    distrito TEXT,
    telefono TEXT,
    direccion TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE public.perfiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Los usuarios pueden ver su propio perfil" ON public.perfiles;
CREATE POLICY "Los usuarios pueden ver su propio perfil"
    ON public.perfiles FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Los usuarios pueden insertar su propio perfil" ON public.perfiles;
CREATE POLICY "Los usuarios pueden insertar su propio perfil"
    ON public.perfiles FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Los usuarios pueden actualizar su propio perfil" ON public.perfiles;
CREATE POLICY "Los usuarios pueden actualizar su propio perfil"
    ON public.perfiles FOR UPDATE USING (auth.uid() = id);

-- ============================================================================
-- 2. TABLA: cursos
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.cursos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    nombre TEXT NOT NULL,
    asignatura TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Agregar columnas si no existen
DO $$
BEGIN
    ALTER TABLE public.cursos ADD COLUMN IF NOT EXISTS secciones TEXT;
    ALTER TABLE public.cursos ADD COLUMN IF NOT EXISTS oculto BOOLEAN DEFAULT false;
    ALTER TABLE public.cursos ADD COLUMN IF NOT EXISTS activo BOOLEAN DEFAULT false;
END $$;

CREATE INDEX IF NOT EXISTS idx_cursos_user_id ON public.cursos(user_id);
CREATE INDEX IF NOT EXISTS idx_cursos_activo ON public.cursos(activo);

ALTER TABLE public.cursos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios cursos" ON public.cursos;
CREATE POLICY "Los usuarios pueden ver sus propios cursos"
    ON public.cursos FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propios cursos" ON public.cursos;
CREATE POLICY "Los usuarios pueden insertar sus propios cursos"
    ON public.cursos FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propios cursos" ON public.cursos;
CREATE POLICY "Los usuarios pueden actualizar sus propios cursos"
    ON public.cursos FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propios cursos" ON public.cursos;
CREATE POLICY "Los usuarios pueden eliminar sus propios cursos"
    ON public.cursos FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- 3. TABLA: estudiantes
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.estudiantes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    curso_id UUID REFERENCES public.cursos(id) ON DELETE CASCADE NOT NULL,
    nombre TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Agregar TODAS las columnas si no existen
DO $$
BEGIN
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS apellido TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS sexo TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS fecha_nacimiento DATE;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS edad INTEGER;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS cedula TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS rne TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS lugar_residencia TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS provincia TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS municipio TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS sector TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS correo_electronico TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS telefono TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS centro_educativo TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS regional TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS distrito TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS repite_grado BOOLEAN DEFAULT false;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS nuevo_ingreso BOOLEAN DEFAULT false;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS promovido BOOLEAN DEFAULT false;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS contacto_emergencia_nombre TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS contacto_emergencia_telefono TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS contacto_emergencia_parentesco TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS seccion TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS numero_orden INTEGER;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS foto_url TEXT;
    ALTER TABLE public.estudiantes ADD COLUMN IF NOT EXISTS observaciones TEXT;
END $$;

CREATE INDEX IF NOT EXISTS idx_estudiantes_curso_id ON public.estudiantes(curso_id);
CREATE INDEX IF NOT EXISTS idx_estudiantes_numero_orden ON public.estudiantes(numero_orden);

ALTER TABLE public.estudiantes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Los usuarios pueden ver estudiantes de sus cursos" ON public.estudiantes;
CREATE POLICY "Los usuarios pueden ver estudiantes de sus cursos"
    ON public.estudiantes FOR SELECT
    USING (curso_id IN (SELECT id FROM public.cursos WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS "Los usuarios pueden insertar estudiantes en sus cursos" ON public.estudiantes;
CREATE POLICY "Los usuarios pueden insertar estudiantes en sus cursos"
    ON public.estudiantes FOR INSERT
    WITH CHECK (curso_id IN (SELECT id FROM public.cursos WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS "Los usuarios pueden actualizar estudiantes de sus cursos" ON public.estudiantes;
CREATE POLICY "Los usuarios pueden actualizar estudiantes de sus cursos"
    ON public.estudiantes FOR UPDATE
    USING (curso_id IN (SELECT id FROM public.cursos WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS "Los usuarios pueden eliminar estudiantes de sus cursos" ON public.estudiantes;
CREATE POLICY "Los usuarios pueden eliminar estudiantes de sus cursos"
    ON public.estudiantes FOR DELETE
    USING (curso_id IN (SELECT id FROM public.cursos WHERE user_id = auth.uid()));

-- ============================================================================
-- 4-17. TABLAS RESTANTES (JSONB)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.datos_generales_estudiantes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso_id TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, curso_id)
);
CREATE INDEX IF NOT EXISTS idx_datos_generales_user_id ON public.datos_generales_estudiantes(user_id);
ALTER TABLE public.datos_generales_estudiantes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios datos generales" ON public.datos_generales_estudiantes;
CREATE POLICY "Los usuarios pueden ver sus propios datos generales"
    ON public.datos_generales_estudiantes FOR ALL USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.condicion_inicial_estudiantes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso_id TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, curso_id)
);
CREATE INDEX IF NOT EXISTS idx_condicion_inicial_user_id ON public.condicion_inicial_estudiantes(user_id);
ALTER TABLE public.condicion_inicial_estudiantes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Los usuarios pueden ver su propia condición inicial" ON public.condicion_inicial_estudiantes;
CREATE POLICY "Los usuarios pueden ver su propia condición inicial"
    ON public.condicion_inicial_estudiantes FOR ALL USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.datos_emergencias_estudiantes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso_id TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, curso_id)
);
CREATE INDEX IF NOT EXISTS idx_datos_emergencias_user_id ON public.datos_emergencias_estudiantes(user_id);
ALTER TABLE public.datos_emergencias_estudiantes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios datos de emergencias" ON public.datos_emergencias_estudiantes;
CREATE POLICY "Los usuarios pueden ver sus propios datos de emergencias"
    ON public.datos_emergencias_estudiantes FOR ALL USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.parentesco_estudiantes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso_id TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, curso_id)
);
CREATE INDEX IF NOT EXISTS idx_parentesco_user_id ON public.parentesco_estudiantes(user_id);
ALTER TABLE public.parentesco_estudiantes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios datos de parentesco" ON public.parentesco_estudiantes;
CREATE POLICY "Los usuarios pueden ver sus propios datos de parentesco"
    ON public.parentesco_estudiantes FOR ALL USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.asistencia_registros_meses (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, curso, seccion)
);
CREATE INDEX IF NOT EXISTS idx_asistencia_registros_user_id ON public.asistencia_registros_meses(user_id);
ALTER TABLE public.asistencia_registros_meses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios registros de asistencia" ON public.asistencia_registros_meses;
CREATE POLICY "Los usuarios pueden ver sus propios registros de asistencia"
    ON public.asistencia_registros_meses FOR ALL USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.asistencia_datos_mes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    mes TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, curso, seccion, mes)
);
CREATE INDEX IF NOT EXISTS idx_asistencia_datos_mes_user_id ON public.asistencia_datos_mes(user_id);
ALTER TABLE public.asistencia_datos_mes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios datos de asistencia mensual" ON public.asistencia_datos_mes;
CREATE POLICY "Los usuarios pueden ver sus propios datos de asistencia mensual"
    ON public.asistencia_datos_mes FOR ALL USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.calificaciones_notas_grupos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, curso, seccion)
);
CREATE INDEX IF NOT EXISTS idx_calificaciones_notas_user_id ON public.calificaciones_notas_grupos(user_id);
ALTER TABLE public.calificaciones_notas_grupos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propias calificaciones" ON public.calificaciones_notas_grupos;
CREATE POLICY "Los usuarios pueden ver sus propias calificaciones"
    ON public.calificaciones_notas_grupos FOR ALL USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.nombres_grupos_calificaciones (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    nombres JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, curso, seccion)
);
CREATE INDEX IF NOT EXISTS idx_nombres_grupos_user_id ON public.nombres_grupos_calificaciones(user_id);
ALTER TABLE public.nombres_grupos_calificaciones ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios nombres de grupos" ON public.nombres_grupos_calificaciones;
CREATE POLICY "Los usuarios pueden ver sus propios nombres de grupos"
    ON public.nombres_grupos_calificaciones FOR ALL USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.promocion_grado_datos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso_id TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, curso_id)
);
CREATE INDEX IF NOT EXISTS idx_promocion_grado_user_id ON public.promocion_grado_datos(user_id);
ALTER TABLE public.promocion_grado_datos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios datos de promoción" ON public.promocion_grado_datos;
CREATE POLICY "Los usuarios pueden ver sus propios datos de promoción"
    ON public.promocion_grado_datos FOR ALL USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.evaluaciones_dias (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso_id TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, curso_id)
);
CREATE INDEX IF NOT EXISTS idx_evaluaciones_dias_user_id ON public.evaluaciones_dias(user_id);
ALTER TABLE public.evaluaciones_dias ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propias evaluaciones" ON public.evaluaciones_dias;
CREATE POLICY "Los usuarios pueden ver sus propias evaluaciones"
    ON public.evaluaciones_dias FOR ALL USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.configuraciones_horario (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    configuracion TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id)
);
CREATE INDEX IF NOT EXISTS idx_configuraciones_horario_user_id ON public.configuraciones_horario(user_id);
ALTER TABLE public.configuraciones_horario ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Los usuarios pueden ver su propia configuración de horario" ON public.configuraciones_horario;
CREATE POLICY "Los usuarios pueden ver su propia configuración de horario"
    ON public.configuraciones_horario FOR ALL USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.eventos_calendario (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    titulo TEXT NOT NULL,
    descripcion TEXT,
    fecha DATE NOT NULL,
    hora_inicio TEXT,
    hora_fin TEXT,
    tipo TEXT,
    color TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_eventos_calendario_user_id ON public.eventos_calendario(user_id);
CREATE INDEX IF NOT EXISTS idx_eventos_calendario_fecha ON public.eventos_calendario(fecha);
ALTER TABLE public.eventos_calendario ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios eventos" ON public.eventos_calendario;
CREATE POLICY "Los usuarios pueden ver sus propios eventos"
    ON public.eventos_calendario FOR ALL USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.datos_centro_educativo (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    nombre_centro TEXT,
    codigo_centro TEXT,
    regional TEXT,
    distrito TEXT,
    direccion TEXT,
    telefono TEXT,
    director TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id)
);
CREATE INDEX IF NOT EXISTS idx_datos_centro_user_id ON public.datos_centro_educativo(user_id);
ALTER TABLE public.datos_centro_educativo ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios datos del centro" ON public.datos_centro_educativo;
CREATE POLICY "Los usuarios pueden ver sus propios datos del centro"
    ON public.datos_centro_educativo FOR ALL USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.notas (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    titulo TEXT NOT NULL,
    contenido TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_notas_user_id ON public.notas(user_id);
CREATE INDEX IF NOT EXISTS idx_notas_updated_at ON public.notas(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_notas_titulo_contenido ON public.notas
    USING gin(to_tsvector('spanish', titulo || ' ' || COALESCE(contenido, '')));
ALTER TABLE public.notas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Los usuarios pueden ver sus propias notas" ON public.notas;
CREATE POLICY "Los usuarios pueden ver sus propias notas"
    ON public.notas FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propias notas" ON public.notas;
CREATE POLICY "Los usuarios pueden insertar sus propias notas"
    ON public.notas FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propias notas" ON public.notas;
CREATE POLICY "Los usuarios pueden actualizar sus propias notas"
    ON public.notas FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propias notas" ON public.notas;
CREATE POLICY "Los usuarios pueden eliminar sus propias notas"
    ON public.notas FOR DELETE USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION update_notas_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notas_updated_at ON public.notas;
CREATE TRIGGER trigger_notas_updated_at
    BEFORE UPDATE ON public.notas
    FOR EACH ROW
    EXECUTE FUNCTION update_notas_updated_at();

-- ============================================================================
-- STORAGE BUCKET
-- ============================================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('perfiles', 'perfiles', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
