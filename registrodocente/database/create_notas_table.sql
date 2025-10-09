-- Tabla para almacenar notas de los usuarios
CREATE TABLE IF NOT EXISTS notas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    titulo TEXT NOT NULL,
    contenido TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_notas_user_id ON notas(user_id);
CREATE INDEX IF NOT EXISTS idx_notas_updated_at ON notas(updated_at DESC);

-- Índice de búsqueda de texto completo
CREATE INDEX IF NOT EXISTS idx_notas_titulo_contenido ON notas USING gin(to_tsvector('spanish', titulo || ' ' || COALESCE(contenido, '')));

-- Habilitar RLS (Row Level Security)
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

-- Función para actualizar automáticamente el campo updated_at
CREATE OR REPLACE FUNCTION update_notas_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar updated_at automáticamente
DROP TRIGGER IF EXISTS trigger_notas_updated_at ON notas;
CREATE TRIGGER trigger_notas_updated_at
    BEFORE UPDATE ON notas
    FOR EACH ROW
    EXECUTE FUNCTION update_notas_updated_at();

-- Comentarios para documentación
COMMENT ON TABLE notas IS 'Almacena las notas personales de los usuarios';
COMMENT ON COLUMN notas.id IS 'Identificador único de la nota';
COMMENT ON COLUMN notas.user_id IS 'ID del usuario propietario de la nota';
COMMENT ON COLUMN notas.titulo IS 'Título de la nota';
COMMENT ON COLUMN notas.contenido IS 'Contenido completo de la nota';
COMMENT ON COLUMN notas.created_at IS 'Fecha de creación de la nota';
COMMENT ON COLUMN notas.updated_at IS 'Fecha de última actualización de la nota';
