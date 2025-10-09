-- Tabla para guardar los datos generales de estudiantes (estilo hoja de cálculo)
-- Esta tabla almacena los datos en formato tabla con 40 filas de estudiantes

CREATE TABLE IF NOT EXISTS datos_generales_estudiantes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  curso_id TEXT NOT NULL,

  -- Datos en formato JSON
  -- {
  --   "nombres": ["Nombre 1", "Nombre 2", ...],  // Array de 40 nombres
  --   "campos_adicionales": [
  --     {"col_0": "M", "col_1": "15", "col_2": "05", "col_3": "2010", ...},  // Fila 1
  --     {"col_0": "F", "col_1": "20", "col_2": "08", "col_3": "2009", ...},  // Fila 2
  --     ...
  --   ]
  -- }
  datos JSONB NOT NULL,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Un usuario solo puede tener un registro de datos generales por curso
  CONSTRAINT unique_user_curso_datos_generales UNIQUE (user_id, curso_id)
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_datos_generales_user_id ON datos_generales_estudiantes(user_id);
CREATE INDEX IF NOT EXISTS idx_datos_generales_curso_id ON datos_generales_estudiantes(curso_id);
CREATE INDEX IF NOT EXISTS idx_datos_generales_user_curso ON datos_generales_estudiantes(user_id, curso_id);

-- Habilitar Row Level Security (RLS)
ALTER TABLE datos_generales_estudiantes ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver sus propios datos
CREATE POLICY "Users can view own datos generales"
  ON datos_generales_estudiantes
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden insertar sus propios datos
CREATE POLICY "Users can insert own datos generales"
  ON datos_generales_estudiantes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden actualizar sus propios datos
CREATE POLICY "Users can update own datos generales"
  ON datos_generales_estudiantes
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden eliminar sus propios datos
CREATE POLICY "Users can delete own datos generales"
  ON datos_generales_estudiantes
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para actualizar updated_at en cada actualización
DROP TRIGGER IF EXISTS update_datos_generales_estudiantes_updated_at ON datos_generales_estudiantes;
CREATE TRIGGER update_datos_generales_estudiantes_updated_at
    BEFORE UPDATE ON datos_generales_estudiantes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios para documentación
COMMENT ON TABLE datos_generales_estudiantes IS 'Almacena los datos generales de estudiantes en formato tabla (40 filas)';
COMMENT ON COLUMN datos_generales_estudiantes.user_id IS 'ID del usuario propietario de estos datos';
COMMENT ON COLUMN datos_generales_estudiantes.curso_id IS 'ID del curso al que pertenecen estos datos';
COMMENT ON COLUMN datos_generales_estudiantes.datos IS 'JSON con nombres y campos adicionales organizados en filas y columnas';
