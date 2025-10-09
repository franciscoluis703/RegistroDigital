-- =====================================================
-- ESQUEMA COMPLETO DE BASE DE DATOS CON RLS
-- Registro Docente - Persistencia Total por Usuario
-- =====================================================

-- PASO 1: Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- TABLA: profiles (Perfiles de usuario extendidos)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    nombre_completo TEXT,
    telefono TEXT,
    centro_educativo TEXT,
    regional TEXT,
    distrito TEXT,
    avatar_url TEXT,
    rol TEXT DEFAULT 'docente',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS para profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para profiles
CREATE POLICY "Los usuarios pueden ver su propio perfil"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Los usuarios pueden actualizar su propio perfil"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Los usuarios pueden insertar su propio perfil"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- =====================================================
-- TABLA: cursos (Cursos/Clases del docente)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.cursos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    nombre TEXT NOT NULL, -- ej: "5to Grado A - Matemáticas"
    grado TEXT NOT NULL,
    seccion TEXT NOT NULL,
    asignatura TEXT NOT NULL,
    año_escolar TEXT NOT NULL,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para rendimiento
CREATE INDEX IF NOT EXISTS idx_cursos_user_id ON public.cursos(user_id);
CREATE INDEX IF NOT EXISTS idx_cursos_activo ON public.cursos(activo);

-- RLS para cursos
ALTER TABLE public.cursos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver sus propios cursos"
    ON public.cursos FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden crear sus propios cursos"
    ON public.cursos FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden actualizar sus propios cursos"
    ON public.cursos FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden eliminar sus propios cursos"
    ON public.cursos FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABLA: estudiantes
-- =====================================================
CREATE TABLE IF NOT EXISTS public.estudiantes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso_id UUID REFERENCES public.cursos(id) ON DELETE CASCADE NOT NULL,
    numero INT NOT NULL, -- Número de orden (1-40)
    nombre_completo TEXT NOT NULL,
    cedula TEXT,
    fecha_nacimiento DATE,
    genero TEXT,
    -- Datos generales
    direccion TEXT,
    telefono TEXT,
    email TEXT,
    -- Condición inicial
    condicion_inicial TEXT, -- promovido, repitente, reingreso, aplazado
    -- Parentesco
    nombre_padre TEXT,
    telefono_padre TEXT,
    nombre_madre TEXT,
    telefono_madre TEXT,
    nombre_tutor TEXT,
    telefono_tutor TEXT,
    -- Datos emergencia
    enfermedades TEXT,
    medicamentos TEXT,
    contacto_emergencia_nombre TEXT,
    contacto_emergencia_telefono TEXT,
    contacto_emergencia_parentesco TEXT,
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(curso_id, numero) -- Evitar duplicados de número en el mismo curso
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_estudiantes_user_id ON public.estudiantes(user_id);
CREATE INDEX IF NOT EXISTS idx_estudiantes_curso_id ON public.estudiantes(curso_id);
CREATE INDEX IF NOT EXISTS idx_estudiantes_numero ON public.estudiantes(numero);

-- RLS para estudiantes
ALTER TABLE public.estudiantes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver sus propios estudiantes"
    ON public.estudiantes FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden crear sus propios estudiantes"
    ON public.estudiantes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden actualizar sus propios estudiantes"
    ON public.estudiantes FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden eliminar sus propios estudiantes"
    ON public.estudiantes FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABLA: asistencia
-- =====================================================
CREATE TABLE IF NOT EXISTS public.asistencia (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso_id UUID REFERENCES public.cursos(id) ON DELETE CASCADE NOT NULL,
    estudiante_id UUID REFERENCES public.estudiantes(id) ON DELETE CASCADE NOT NULL,
    fecha DATE NOT NULL,
    mes TEXT NOT NULL, -- "Enero", "Febrero", etc.
    año INT NOT NULL,
    estado TEXT NOT NULL, -- P (Presente), A (Ausente), T (Tardanza), J (Justificado)
    observaciones TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(estudiante_id, fecha) -- Un estudiante no puede tener múltiples asistencias en la misma fecha
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_asistencia_user_id ON public.asistencia(user_id);
CREATE INDEX IF NOT EXISTS idx_asistencia_curso_id ON public.asistencia(curso_id);
CREATE INDEX IF NOT EXISTS idx_asistencia_estudiante_id ON public.asistencia(estudiante_id);
CREATE INDEX IF NOT EXISTS idx_asistencia_fecha ON public.asistencia(fecha);
CREATE INDEX IF NOT EXISTS idx_asistencia_mes_año ON public.asistencia(mes, año);

-- RLS para asistencia
ALTER TABLE public.asistencia ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver su propia asistencia"
    ON public.asistencia FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden crear su propia asistencia"
    ON public.asistencia FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden actualizar su propia asistencia"
    ON public.asistencia FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden eliminar su propia asistencia"
    ON public.asistencia FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABLA: calificaciones
-- =====================================================
CREATE TABLE IF NOT EXISTS public.calificaciones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso_id UUID REFERENCES public.cursos(id) ON DELETE CASCADE NOT NULL,
    estudiante_id UUID REFERENCES public.estudiantes(id) ON DELETE CASCADE NOT NULL,
    periodo TEXT NOT NULL, -- "Grupo 1", "Grupo 2", "Grupo 3", "Grupo 4"
    tipo TEXT NOT NULL, -- "P1", "RP1", "P2", "RP2", "P3", "RP3", "P4", "RP4"
    calificacion DECIMAL(5,2),
    año_escolar TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(estudiante_id, periodo, tipo, año_escolar)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_calificaciones_user_id ON public.calificaciones(user_id);
CREATE INDEX IF NOT EXISTS idx_calificaciones_curso_id ON public.calificaciones(curso_id);
CREATE INDEX IF NOT EXISTS idx_calificaciones_estudiante_id ON public.calificaciones(estudiante_id);
CREATE INDEX IF NOT EXISTS idx_calificaciones_periodo ON public.calificaciones(periodo);

-- RLS para calificaciones
ALTER TABLE public.calificaciones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver sus propias calificaciones"
    ON public.calificaciones FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden crear sus propias calificaciones"
    ON public.calificaciones FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden actualizar sus propias calificaciones"
    ON public.calificaciones FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden eliminar sus propias calificaciones"
    ON public.calificaciones FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABLA: promocion_grado
-- =====================================================
CREATE TABLE IF NOT EXISTS public.promocion_grado (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso_id UUID REFERENCES public.cursos(id) ON DELETE CASCADE NOT NULL,
    estudiante_id UUID REFERENCES public.estudiantes(id) ON DELETE CASCADE NOT NULL,
    calificacion_final DECIMAL(5,2),
    calificacion_completiva DECIMAL(5,2),
    calificacion_completiva_final DECIMAL(5,2),
    calificacion_extraordinaria DECIMAL(5,2),
    calificacion_extraordinaria_final DECIMAL(5,2),
    calificacion_especial_cf DECIMAL(5,2),
    calificacion_especial_ce DECIMAL(5,2),
    calificacion_especial_final DECIMAL(5,2),
    estado_final TEXT, -- "Promovido", "Reprobado", "Pendiente"
    año_escolar TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(estudiante_id, año_escolar)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_promocion_user_id ON public.promocion_grado(user_id);
CREATE INDEX IF NOT EXISTS idx_promocion_curso_id ON public.promocion_grado(curso_id);
CREATE INDEX IF NOT EXISTS idx_promocion_estudiante_id ON public.promocion_grado(estudiante_id);

-- RLS para promocion_grado
ALTER TABLE public.promocion_grado ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver su propia promoción"
    ON public.promocion_grado FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden crear su propia promoción"
    ON public.promocion_grado FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden actualizar su propia promoción"
    ON public.promocion_grado FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden eliminar su propia promoción"
    ON public.promocion_grado FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABLA: horarios
-- =====================================================
CREATE TABLE IF NOT EXISTS public.horarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    curso_id UUID REFERENCES public.cursos(id) ON DELETE CASCADE,
    dia_semana TEXT NOT NULL, -- Lunes, Martes, etc.
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    asignatura TEXT NOT NULL,
    aula TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_horarios_user_id ON public.horarios(user_id);
CREATE INDEX IF NOT EXISTS idx_horarios_curso_id ON public.horarios(curso_id);
CREATE INDEX IF NOT EXISTS idx_horarios_dia_semana ON public.horarios(dia_semana);

-- RLS para horarios
ALTER TABLE public.horarios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver sus propios horarios"
    ON public.horarios FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden crear sus propios horarios"
    ON public.horarios FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden actualizar sus propios horarios"
    ON public.horarios FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden eliminar sus propios horarios"
    ON public.horarios FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABLA: user_activity_logs (Registro de actividades)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    action TEXT NOT NULL, -- "create", "update", "delete", "login", "logout"
    entity_type TEXT NOT NULL, -- "estudiante", "asistencia", "calificacion", etc.
    entity_id UUID, -- ID del registro afectado
    details JSONB, -- Información adicional en formato JSON
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para rendimiento en consultas de logs
CREATE INDEX IF NOT EXISTS idx_activity_logs_user_id ON public.user_activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_timestamp ON public.user_activity_logs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_activity_logs_action ON public.user_activity_logs(action);
CREATE INDEX IF NOT EXISTS idx_activity_logs_entity_type ON public.user_activity_logs(entity_type);

-- RLS para activity logs
ALTER TABLE public.user_activity_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver sus propios logs"
    ON public.user_activity_logs FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden crear sus propios logs"
    ON public.user_activity_logs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- TABLA: sync_queue (Cola de sincronización offline)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.sync_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    operation TEXT NOT NULL, -- "insert", "update", "delete"
    table_name TEXT NOT NULL,
    data JSONB NOT NULL,
    status TEXT DEFAULT 'pending', -- "pending", "processing", "completed", "failed"
    error_message TEXT,
    retry_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_sync_queue_user_id ON public.sync_queue(user_id);
CREATE INDEX IF NOT EXISTS idx_sync_queue_status ON public.sync_queue(status);
CREATE INDEX IF NOT EXISTS idx_sync_queue_created_at ON public.sync_queue(created_at);

-- RLS para sync_queue
ALTER TABLE public.sync_queue ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver su propia cola"
    ON public.sync_queue FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden crear en su propia cola"
    ON public.sync_queue FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden actualizar su propia cola"
    ON public.sync_queue FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden eliminar de su propia cola"
    ON public.sync_queue FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- FUNCIONES Y TRIGGERS
-- =====================================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a todas las tablas relevantes
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cursos_updated_at
    BEFORE UPDATE ON public.cursos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_estudiantes_updated_at
    BEFORE UPDATE ON public.estudiantes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_asistencia_updated_at
    BEFORE UPDATE ON public.asistencia
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_calificaciones_updated_at
    BEFORE UPDATE ON public.calificaciones
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_promocion_grado_updated_at
    BEFORE UPDATE ON public.promocion_grado
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_horarios_updated_at
    BEFORE UPDATE ON public.horarios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Función para crear perfil automáticamente cuando se registra un usuario
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, nombre_completo)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'nombre_completo', NEW.email)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para crear perfil al registrarse
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- DATOS DE EJEMPLO - ELIMINADOS
-- =====================================================
-- Los datos de ejemplo han sido eliminados
-- Los perfiles se crean automáticamente al registrarse mediante el trigger on_auth_user_created

-- =====================================================
-- SCRIPT COMPLETADO
-- =====================================================
-- Para ejecutar este script:
-- 1. Ve a tu proyecto de Supabase: https://supabase.com/dashboard
-- 2. Selecciona tu proyecto
-- 3. Ve a SQL Editor
-- 4. Copia y pega este script completo
-- 5. Haz clic en "Run"
-- 6. Verifica que todas las tablas se hayan creado correctamente
