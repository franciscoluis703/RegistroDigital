-- ============================================================================
-- SCRIPT COMPLETO PARA CONFIGURAR TODAS LAS TABLAS EN SUPABASE
-- ============================================================================
-- Ejecuta este script completo en el SQL Editor de Supabase
-- ============================================================================

-- ============================================================================
-- 1. TABLA PARA NOTAS (BLOC DE NOTAS)
-- ============================================================================

-- Tabla para almacenar notas de los usuarios
CREATE TABLE IF NOT EXISTS notas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    titulo TEXT NOT NULL,
    contenido TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Índices para optimizar consultas de notas
CREATE INDEX IF NOT EXISTS idx_notas_user_id ON notas(user_id);
CREATE INDEX IF NOT EXISTS idx_notas_updated_at ON notas(updated_at DESC);

-- Índice de búsqueda de texto completo en español
CREATE INDEX IF NOT EXISTS idx_notas_titulo_contenido ON notas USING gin(to_tsvector('spanish', titulo || ' ' || COALESCE(contenido, '')));

-- Habilitar RLS (Row Level Security) para notas
ALTER TABLE notas ENABLE ROW LEVEL SECURITY;

-- Política para que los usuarios solo puedan ver sus propias notas
CREATE POLICY "Los usuarios pueden ver sus propias notas"
    ON notas
    FOR SELECT
    USING (auth.uid() = user_id);

-- Política para que los usuarios solo puedan insertar sus propias notas
CREATE POLICY "Los usuarios pueden insertar sus propias notas"
    ON notas
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Política para que los usuarios solo puedan actualizar sus propias notas
CREATE POLICY "Los usuarios pueden actualizar sus propias notas"
    ON notas
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Política para que los usuarios solo puedan eliminar sus propias notas
CREATE POLICY "Los usuarios pueden eliminar sus propias notas"
    ON notas
    FOR DELETE
    USING (auth.uid() = user_id);

-- Función para actualizar automáticamente el campo updated_at de notas
CREATE OR REPLACE FUNCTION update_notas_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar updated_at automáticamente en notas
DROP TRIGGER IF EXISTS trigger_notas_updated_at ON notas;
CREATE TRIGGER trigger_notas_updated_at
    BEFORE UPDATE ON notas
    FOR EACH ROW
    EXECUTE FUNCTION update_notas_updated_at();

-- Comentarios para documentación de notas
COMMENT ON TABLE notas IS 'Almacena las notas personales de los usuarios';
COMMENT ON COLUMN notas.id IS 'Identificador único de la nota';
COMMENT ON COLUMN notas.user_id IS 'ID del usuario propietario de la nota';
COMMENT ON COLUMN notas.titulo IS 'Título de la nota';
COMMENT ON COLUMN notas.contenido IS 'Contenido completo de la nota';
COMMENT ON COLUMN notas.created_at IS 'Fecha de creación de la nota';
COMMENT ON COLUMN notas.updated_at IS 'Fecha de última actualización de la nota';


-- ============================================================================
-- 2. TABLA PARA NOMBRES DE GRUPOS PERSONALIZADOS (CALIFICACIONES)
-- ============================================================================

-- Tabla para almacenar nombres personalizados de los grupos de calificaciones
CREATE TABLE IF NOT EXISTS nombres_grupos_calificaciones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    nombres JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, curso, seccion)
);

-- Índices para optimizar consultas de nombres de grupos
CREATE INDEX IF NOT EXISTS idx_nombres_grupos_user_id ON nombres_grupos_calificaciones(user_id);
CREATE INDEX IF NOT EXISTS idx_nombres_grupos_curso_seccion ON nombres_grupos_calificaciones(curso, seccion);

-- Habilitar RLS (Row Level Security) para nombres de grupos
ALTER TABLE nombres_grupos_calificaciones ENABLE ROW LEVEL SECURITY;

-- Política para que los usuarios solo puedan ver sus propios datos
CREATE POLICY "Los usuarios pueden ver sus propios nombres de grupos"
    ON nombres_grupos_calificaciones
    FOR SELECT
    USING (auth.uid() = user_id);

-- Política para que los usuarios solo puedan insertar sus propios datos
CREATE POLICY "Los usuarios pueden insertar sus propios nombres de grupos"
    ON nombres_grupos_calificaciones
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Política para que los usuarios solo puedan actualizar sus propios datos
CREATE POLICY "Los usuarios pueden actualizar sus propios nombres de grupos"
    ON nombres_grupos_calificaciones
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Política para que los usuarios solo puedan eliminar sus propios datos
CREATE POLICY "Los usuarios pueden eliminar sus propios nombres de grupos"
    ON nombres_grupos_calificaciones
    FOR DELETE
    USING (auth.uid() = user_id);

-- Comentarios para documentación de nombres de grupos
COMMENT ON TABLE nombres_grupos_calificaciones IS 'Almacena los nombres personalizados de los grupos de calificaciones (Grupo 1, Grupo 2, Grupo 3, Grupo 4)';
COMMENT ON COLUMN nombres_grupos_calificaciones.nombres IS 'Objeto JSON con las claves grupo1, grupo2, grupo3, grupo4 y sus nombres personalizados';


-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
-- Después de ejecutar este script:
-- 1. Verifica que las tablas aparezcan en el Table Editor de Supabase
-- 2. Las tablas creadas son: notas, nombres_grupos_calificaciones
-- 3. Reinicia tu aplicación Flutter para que los cambios tomen efecto
-- ============================================================================
