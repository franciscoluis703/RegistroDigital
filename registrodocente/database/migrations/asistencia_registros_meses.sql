-- Tabla para guardar los registros de meses de asistencia
-- Esta tabla almacena la lista de 10 meses creados para cada curso/sección

CREATE TABLE IF NOT EXISTS asistencia_registros_meses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  curso TEXT NOT NULL,
  seccion TEXT NOT NULL,

  -- Datos en formato JSON
  -- {
  --   "registros": [
  --     {"mes": "Agosto", "materia": "4to", "seccion": "A"},
  --     {"mes": "Septiembre", "materia": "4to", "seccion": "A"},
  --     ...
  --   ]
  -- }
  datos JSONB NOT NULL,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Un usuario solo puede tener un registro de meses por curso/sección
  CONSTRAINT unique_user_curso_seccion_meses UNIQUE (user_id, curso, seccion)
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_asistencia_meses_user_id ON asistencia_registros_meses(user_id);
CREATE INDEX IF NOT EXISTS idx_asistencia_meses_curso ON asistencia_registros_meses(curso);
CREATE INDEX IF NOT EXISTS idx_asistencia_meses_user_curso ON asistencia_registros_meses(user_id, curso, seccion);

-- Habilitar Row Level Security (RLS)
ALTER TABLE asistencia_registros_meses ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver sus propios datos
CREATE POLICY "Users can view own asistencia meses"
  ON asistencia_registros_meses
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden insertar sus propios datos
CREATE POLICY "Users can insert own asistencia meses"
  ON asistencia_registros_meses
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden actualizar sus propios datos
CREATE POLICY "Users can update own asistencia meses"
  ON asistencia_registros_meses
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden eliminar sus propios datos
CREATE POLICY "Users can delete own asistencia meses"
  ON asistencia_registros_meses
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para actualizar updated_at en cada actualización
DROP TRIGGER IF EXISTS update_asistencia_meses_updated_at ON asistencia_registros_meses;
CREATE TRIGGER update_asistencia_meses_updated_at
    BEFORE UPDATE ON asistencia_registros_meses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios para documentación
COMMENT ON TABLE asistencia_registros_meses IS 'Almacena la lista de 10 meses de asistencia por curso/sección';
COMMENT ON COLUMN asistencia_registros_meses.user_id IS 'ID del usuario propietario de estos datos';
COMMENT ON COLUMN asistencia_registros_meses.curso IS 'Curso (Ej: 4to, 5to, etc.)';
COMMENT ON COLUMN asistencia_registros_meses.seccion IS 'Sección (Ej: A, B, etc.)';
COMMENT ON COLUMN asistencia_registros_meses.datos IS 'JSON con lista de 10 meses consecutivos';
