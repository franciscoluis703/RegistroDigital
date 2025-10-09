-- ============================================================================
-- SETUP COMPLETO DE BASE DE DATOS SUPABASE
-- Registro Docente - Todas las tablas necesarias
-- ============================================================================
-- IMPORTANTE: Ejecuta este script completo en el SQL Editor de Supabase
-- ============================================================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. TABLA: perfiles (Perfil del usuario/docente)
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

-- RLS para perfiles
ALTER TABLE public.perfiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver su propio perfil"
    ON public.perfiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Los usuarios pueden insertar su propio perfil"
    ON public.perfiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Los usuarios pueden actualizar su propio perfil"
    ON public.perfiles FOR UPDATE
    USING (auth.uid() = id);

-- ============================================================================
-- 2. TABLA: cursos (Cursos/Clases del docente)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.cursos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    nombre TEXT NOT NULL,
    asignatura TEXT NOT NULL,
    secciones TEXT, -- JSON array de secciones
    oculto BOOLEAN DEFAULT false,
    activo BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_cursos_user_id ON public.cursos(user_id);
CREATE INDEX IF NOT EXISTS idx_cursos_activo ON public.cursos(activo);

-- RLS para cursos
ALTER TABLE public.cursos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver sus propios cursos"
    ON public.cursos FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden insertar sus propios cursos"
    ON public.cursos FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden actualizar sus propios cursos"
    ON public.cursos FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden eliminar sus propios cursos"
    ON public.cursos FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================================
-- 3. TABLA: estudiantes (Datos de estudiantes)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.estudiantes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    curso_id UUID REFERENCES public.cursos(id) ON DELETE CASCADE NOT NULL,
    nombre TEXT NOT NULL,
    apellido TEXT,
    sexo TEXT,
    fecha_nacimiento DATE,
    edad INTEGER,
    cedula TEXT,
    rne TEXT,
    lugar_residencia TEXT,
    provincia TEXT,
    municipio TEXT,
    sector TEXT,
    correo_electronico TEXT,
    telefono TEXT,
    centro_educativo TEXT,
    regional TEXT,
    distrito TEXT,
    repite_grado BOOLEAN DEFAULT false,
    nuevo_ingreso BOOLEAN DEFAULT false,
    promovido BOOLEAN DEFAULT false,
    contacto_emergencia_nombre TEXT,
    contacto_emergencia_telefono TEXT,
    contacto_emergencia_parentesco TEXT,
    seccion TEXT,
    numero_orden INTEGER,
    foto_url TEXT,
    observaciones TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_estudiantes_curso_id ON public.estudiantes(curso_id);
CREATE INDEX IF NOT EXISTS idx_estudiantes_numero_orden ON public.estudiantes(numero_orden);

-- RLS para estudiantes
ALTER TABLE public.estudiantes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver estudiantes de sus cursos"
    ON public.estudiantes FOR SELECT
    USING (curso_id IN (SELECT id FROM public.cursos WHERE user_id = auth.uid()));

CREATE POLICY "Los usuarios pueden insertar estudiantes en sus cursos"
    ON public.estudiantes FOR INSERT
    WITH CHECK (curso_id IN (SELECT id FROM public.cursos WHERE user_id = auth.uid()));

CREATE POLICY "Los usuarios pueden actualizar estudiantes de sus cursos"
    ON public.estudiantes FOR UPDATE
    USING (curso_id IN (SELECT id FROM public.cursos WHERE user_id = auth.uid()));

CREATE POLICY "Los usuarios pueden eliminar estudiantes de sus cursos"
    ON public.estudiantes FOR DELETE
    USING (curso_id IN (SELECT id FROM public.cursos WHERE user_id = auth.uid()));

-- ============================================================================
-- 4. TABLA: datos_generales_estudiantes (Datos generales - formato tabla)
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

CREATE POLICY "Los usuarios pueden ver sus propios datos generales"
    ON public.datos_generales_estudiantes FOR ALL
    USING (auth.uid() = user_id);

-- ============================================================================
-- 5. TABLA: condicion_inicial_estudiantes
-- ============================================================================

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

CREATE POLICY "Los usuarios pueden ver su propia condición inicial"
    ON public.condicion_inicial_estudiantes FOR ALL
    USING (auth.uid() = user_id);

-- ============================================================================
-- 6. TABLA: datos_emergencias_estudiantes
-- ============================================================================

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

CREATE POLICY "Los usuarios pueden ver sus propios datos de emergencias"
    ON public.datos_emergencias_estudiantes FOR ALL
    USING (auth.uid() = user_id);

-- ============================================================================
-- 7. TABLA: parentesco_estudiantes
-- ============================================================================

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

CREATE POLICY "Los usuarios pueden ver sus propios datos de parentesco"
    ON public.parentesco_estudiantes FOR ALL
    USING (auth.uid() = user_id);

-- ============================================================================
-- 8. TABLA: asistencia_registros_meses
-- ============================================================================

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

CREATE POLICY "Los usuarios pueden ver sus propios registros de asistencia"
    ON public.asistencia_registros_meses FOR ALL
    USING (auth.uid() = user_id);

-- ============================================================================
-- 9. TABLA: asistencia_datos_mes
-- ============================================================================

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

CREATE POLICY "Los usuarios pueden ver sus propios datos de asistencia mensual"
    ON public.asistencia_datos_mes FOR ALL
    USING (auth.uid() = user_id);

-- ============================================================================
-- 10. TABLA: calificaciones_notas_grupos
-- ============================================================================

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

CREATE POLICY "Los usuarios pueden ver sus propias calificaciones"
    ON public.calificaciones_notas_grupos FOR ALL
    USING (auth.uid() = user_id);

-- ============================================================================
-- 11. TABLA: nombres_grupos_calificaciones
-- ============================================================================

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

CREATE POLICY "Los usuarios pueden ver sus propios nombres de grupos"
    ON public.nombres_grupos_calificaciones FOR ALL
    USING (auth.uid() = user_id);

-- ============================================================================
-- 12. TABLA: promocion_grado_datos
-- ============================================================================

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

CREATE POLICY "Los usuarios pueden ver sus propios datos de promoción"
    ON public.promocion_grado_datos FOR ALL
    USING (auth.uid() = user_id);

-- ============================================================================
-- 13. TABLA: evaluaciones_dias
-- ============================================================================

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

CREATE POLICY "Los usuarios pueden ver sus propias evaluaciones"
    ON public.evaluaciones_dias FOR ALL
    USING (auth.uid() = user_id);

-- ============================================================================
-- 14. TABLA: configuraciones_horario
-- ============================================================================

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

CREATE POLICY "Los usuarios pueden ver su propia configuración de horario"
    ON public.configuraciones_horario FOR ALL
    USING (auth.uid() = user_id);

-- ============================================================================
-- 15. TABLA: eventos_calendario
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.eventos_calendario (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    titulo TEXT NOT NULL,
    descripcion TEXT,
    fecha DATE NOT NULL,
    hora_inicio TEXT,
    hora_fin TEXT,
    tipo TEXT, -- 'feriado', 'reunion', 'evaluacion', 'actividad', 'otro'
    color TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_eventos_calendario_user_id ON public.eventos_calendario(user_id);
CREATE INDEX IF NOT EXISTS idx_eventos_calendario_fecha ON public.eventos_calendario(fecha);

ALTER TABLE public.eventos_calendario ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver sus propios eventos"
    ON public.eventos_calendario FOR ALL
    USING (auth.uid() = user_id);

-- ============================================================================
-- 16. TABLA: datos_centro_educativo
-- ============================================================================

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

CREATE POLICY "Los usuarios pueden ver sus propios datos del centro"
    ON public.datos_centro_educativo FOR ALL
    USING (auth.uid() = user_id);

-- ============================================================================
-- 17. TABLA: notas (Bloc de Notas)
-- ============================================================================

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

CREATE POLICY "Los usuarios pueden ver sus propias notas"
    ON public.notas FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden insertar sus propias notas"
    ON public.notas FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden actualizar sus propias notas"
    ON public.notas FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden eliminar sus propias notas"
    ON public.notas FOR DELETE
    USING (auth.uid() = user_id);

-- Función para actualizar updated_at automáticamente en notas
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
-- STORAGE BUCKET: perfiles (Para fotos de perfil)
-- ============================================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('perfiles', 'perfiles', true)
ON CONFLICT (id) DO NOTHING;

-- Política de storage para perfiles
CREATE POLICY "Los usuarios pueden subir sus propias fotos de perfil"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'perfiles' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Los usuarios pueden actualizar sus propias fotos de perfil"
    ON storage.objects FOR UPDATE
    USING (bucket_id = 'perfiles' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Todos pueden ver las fotos de perfil"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'perfiles');

CREATE POLICY "Los usuarios pueden eliminar sus propias fotos de perfil"
    ON storage.objects FOR DELETE
    USING (bucket_id = 'perfiles' AND auth.uid()::text = (storage.foldername(name))[1]);

-- ============================================================================
-- COMENTARIOS Y DOCUMENTACIÓN
-- ============================================================================

COMMENT ON TABLE public.perfiles IS 'Perfiles extendidos de los usuarios/docentes';
COMMENT ON TABLE public.cursos IS 'Cursos o clases que maneja el docente';
COMMENT ON TABLE public.estudiantes IS 'Información detallada de los estudiantes';
COMMENT ON TABLE public.datos_generales_estudiantes IS 'Datos generales en formato tabla (JSONB)';
COMMENT ON TABLE public.condicion_inicial_estudiantes IS 'Condición inicial de los estudiantes (promovido, repitente, etc.)';
COMMENT ON TABLE public.datos_emergencias_estudiantes IS 'Datos de contactos de emergencia';
COMMENT ON TABLE public.parentesco_estudiantes IS 'Datos de parentesco de los estudiantes';
COMMENT ON TABLE public.asistencia_registros_meses IS 'Registros de meses de asistencia';
COMMENT ON TABLE public.asistencia_datos_mes IS 'Datos completos de asistencia por mes';
COMMENT ON TABLE public.calificaciones_notas_grupos IS 'Notas de los 4 grupos de calificaciones';
COMMENT ON TABLE public.nombres_grupos_calificaciones IS 'Nombres personalizados de los grupos (GRUPO 1, GRUPO 2, etc.)';
COMMENT ON TABLE public.promocion_grado_datos IS 'Datos de promoción de grado en formato matricial';
COMMENT ON TABLE public.evaluaciones_dias IS 'Datos de evaluaciones por días (1-10)';
COMMENT ON TABLE public.configuraciones_horario IS 'Configuración del horario de clases (persistente)';
COMMENT ON TABLE public.eventos_calendario IS 'Eventos del calendario escolar';
COMMENT ON TABLE public.datos_centro_educativo IS 'Datos del centro educativo del docente';
COMMENT ON TABLE public.notas IS 'Notas personales del docente (Bloc de Notas)';

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================

-- Después de ejecutar este script:
-- 1. Verifica que todas las tablas aparezcan en el Table Editor de Supabase
-- 2. Verifica que el bucket "perfiles" aparezca en Storage
-- 3. Reinicia tu aplicación Flutter (presiona R o ejecuta flutter run de nuevo)
-- 4. Todas las funcionalidades de la app guardarán permanentemente en Supabase

-- Tablas creadas (17 en total):
-- ✓ perfiles
-- ✓ cursos
-- ✓ estudiantes
-- ✓ datos_generales_estudiantes
-- ✓ condicion_inicial_estudiantes
-- ✓ datos_emergencias_estudiantes
-- ✓ parentesco_estudiantes
-- ✓ asistencia_registros_meses
-- ✓ asistencia_datos_mes
-- ✓ calificaciones_notas_grupos
-- ✓ nombres_grupos_calificaciones
-- ✓ promocion_grado_datos
-- ✓ evaluaciones_dias
-- ✓ configuraciones_horario
-- ✓ eventos_calendario
-- ✓ datos_centro_educativo
-- ✓ notas

-- Storage Buckets:
-- ✓ perfiles (para fotos de perfil)
