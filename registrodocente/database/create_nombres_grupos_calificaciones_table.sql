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

-- Índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_nombres_grupos_user_id ON nombres_grupos_calificaciones(user_id);
CREATE INDEX IF NOT EXISTS idx_nombres_grupos_curso_seccion ON nombres_grupos_calificaciones(curso, seccion);

-- Habilitar RLS (Row Level Security)
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

-- Comentarios para documentación
COMMENT ON TABLE nombres_grupos_calificaciones IS 'Almacena los nombres personalizados de los grupos de calificaciones (Grupo 1, Grupo 2, Grupo 3, Grupo 4)';
COMMENT ON COLUMN nombres_grupos_calificaciones.nombres IS 'Objeto JSON con las claves grupo1, grupo2, grupo3, grupo4 y sus nombres personalizados';
