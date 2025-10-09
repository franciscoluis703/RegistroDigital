-- Tabla para guardar los datos de promoción del grado
-- Esta tabla almacena la matriz de promoción con todos los datos de los estudiantes

CREATE TABLE IF NOT EXISTS promocion_grado_datos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  curso_id TEXT NOT NULL,

  -- Datos en formato JSON
  -- {
  --   "datosPromocion": [
  --     ["", "", "", "", ...],  // Fila 1 (estudiante 1): todas las columnas de promoción
  --     ["", "", "", "", ...],  // Fila 2 (estudiante 2): todas las columnas de promoción
  --     ...                     // hasta 40 filas
  --   ],
  --   "asignatura": "Matemática",
  --   "grado": "4to",
  --   "docente": "Nombre del Docente",
  --   "ultimaActualizacion": "2025-01-08T12:00:00Z"
  -- }
  datos JSONB NOT NULL,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Un usuario solo puede tener un registro de promoción por curso
  CONSTRAINT unique_user_curso_promocion UNIQUE (user_id, curso_id)
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_promocion_datos_user_id ON promocion_grado_datos(user_id);
CREATE INDEX IF NOT EXISTS idx_promocion_datos_curso ON promocion_grado_datos(curso_id);
CREATE INDEX IF NOT EXISTS idx_promocion_datos_user_curso ON promocion_grado_datos(user_id, curso_id);

-- Habilitar Row Level Security (RLS)
ALTER TABLE promocion_grado_datos ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver sus propios datos
CREATE POLICY "Users can view own promocion datos"
  ON promocion_grado_datos
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden insertar sus propios datos
CREATE POLICY "Users can insert own promocion datos"
  ON promocion_grado_datos
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden actualizar sus propios datos
CREATE POLICY "Users can update own promocion datos"
  ON promocion_grado_datos
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden eliminar sus propios datos
CREATE POLICY "Users can delete own promocion datos"
  ON promocion_grado_datos
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para actualizar updated_at en cada actualización
DROP TRIGGER IF EXISTS update_promocion_datos_updated_at ON promocion_grado_datos;
CREATE TRIGGER update_promocion_datos_updated_at
    BEFORE UPDATE ON promocion_grado_datos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios para documentación
COMMENT ON TABLE promocion_grado_datos IS 'Almacena los datos completos de promoción del grado (matriz con todos los datos de estudiantes)';
COMMENT ON COLUMN promocion_grado_datos.user_id IS 'ID del usuario propietario de estos datos';
COMMENT ON COLUMN promocion_grado_datos.curso_id IS 'ID del curso (grado_seccion_asignatura)';
COMMENT ON COLUMN promocion_grado_datos.datos IS 'JSON con matriz de promoción, asignatura, grado y docente';
