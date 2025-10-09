-- ============================================================================
-- VERIFICAR Y REPARAR TABLAS DE ASISTENCIA
-- ============================================================================
-- Ejecuta este script en el SQL Editor de Supabase para asegurar que
-- las tablas de asistencia existen y están configuradas correctamente
-- ============================================================================

-- ============================================================================
-- 1. TABLA: asistencia_registros_meses
-- ============================================================================
-- Almacena los registros de meses (lista de 10 meses) para cada curso
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

-- Índices para asistencia_registros_meses
CREATE INDEX IF NOT EXISTS idx_asistencia_registros_meses_user_id ON public.asistencia_registros_meses(user_id);
CREATE INDEX IF NOT EXISTS idx_asistencia_registros_meses_curso_seccion ON public.asistencia_registros_meses(curso, seccion);

-- Habilitar RLS
ALTER TABLE public.asistencia_registros_meses ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes y recrearlas
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios registros de meses" ON public.asistencia_registros_meses;
DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propios registros de meses" ON public.asistencia_registros_meses;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propios registros de meses" ON public.asistencia_registros_meses;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propios registros de meses" ON public.asistencia_registros_meses;

CREATE POLICY "Los usuarios pueden ver sus propios registros de meses"
    ON public.asistencia_registros_meses
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden insertar sus propios registros de meses"
    ON public.asistencia_registros_meses
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden actualizar sus propios registros de meses"
    ON public.asistencia_registros_meses
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden eliminar sus propios registros de meses"
    ON public.asistencia_registros_meses
    FOR DELETE
    USING (auth.uid() = user_id);

-- Comentarios
COMMENT ON TABLE public.asistencia_registros_meses IS 'Almacena los registros de meses de asistencia (lista de 10 meses) para cada curso y sección';
COMMENT ON COLUMN public.asistencia_registros_meses.datos IS 'Objeto JSON con la estructura: {registros: [{mes, anio, diasMes, feriados}]}';

-- ============================================================================
-- 2. TABLA: asistencia_datos_mes
-- ============================================================================
-- Almacena los datos completos de asistencia de un mes específico
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

-- Índices para asistencia_datos_mes
CREATE INDEX IF NOT EXISTS idx_asistencia_datos_mes_user_id ON public.asistencia_datos_mes(user_id);
CREATE INDEX IF NOT EXISTS idx_asistencia_datos_mes_curso_seccion_mes ON public.asistencia_datos_mes(curso, seccion, mes);

-- Habilitar RLS
ALTER TABLE public.asistencia_datos_mes ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes y recrearlas
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propios datos de asistencia" ON public.asistencia_datos_mes;
DROP POLICY IF EXISTS "Los usuarios pueden insertar sus propios datos de asistencia" ON public.asistencia_datos_mes;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus propios datos de asistencia" ON public.asistencia_datos_mes;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus propios datos de asistencia" ON public.asistencia_datos_mes;

CREATE POLICY "Los usuarios pueden ver sus propios datos de asistencia"
    ON public.asistencia_datos_mes
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden insertar sus propios datos de asistencia"
    ON public.asistencia_datos_mes
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden actualizar sus propios datos de asistencia"
    ON public.asistencia_datos_mes
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden eliminar sus propios datos de asistencia"
    ON public.asistencia_datos_mes
    FOR DELETE
    USING (auth.uid() = user_id);

-- Comentarios
COMMENT ON TABLE public.asistencia_datos_mes IS 'Almacena los datos completos de asistencia de un mes específico (matriz de asistencia, feriados, días del mes)';
COMMENT ON COLUMN public.asistencia_datos_mes.datos IS 'Objeto JSON con la estructura: {asistencia: [[]], feriados: {}, diasMes: [], ultimaActualizacion: ""}';

-- ============================================================================
-- 3. FUNCIÓN PARA ACTUALIZAR updated_at AUTOMÁTICAMENTE
-- ============================================================================

-- Para asistencia_registros_meses
CREATE OR REPLACE FUNCTION update_asistencia_registros_meses_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_asistencia_registros_meses_updated_at ON public.asistencia_registros_meses;
CREATE TRIGGER trigger_asistencia_registros_meses_updated_at
    BEFORE UPDATE ON public.asistencia_registros_meses
    FOR EACH ROW
    EXECUTE FUNCTION update_asistencia_registros_meses_updated_at();

-- Para asistencia_datos_mes
CREATE OR REPLACE FUNCTION update_asistencia_datos_mes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_asistencia_datos_mes_updated_at ON public.asistencia_datos_mes;
CREATE TRIGGER trigger_asistencia_datos_mes_updated_at
    BEFORE UPDATE ON public.asistencia_datos_mes
    FOR EACH ROW
    EXECUTE FUNCTION update_asistencia_datos_mes_updated_at();

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
-- Después de ejecutar este script:
-- 1. Ve al Table Editor de Supabase
-- 2. Verifica que las tablas asistencia_registros_meses y asistencia_datos_mes existan
-- 3. IMPORTANTE: Haz clic en "Refresh Schema Cache" en Supabase (Settings > API)
-- 4. Reinicia tu aplicación Flutter
-- ============================================================================
