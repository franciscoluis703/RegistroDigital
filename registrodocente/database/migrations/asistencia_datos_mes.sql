-- Tabla para guardar los datos completos de asistencia de un mes
-- Esta tabla almacena la matriz de asistencia (40 estudiantes x 22 columnas) más feriados y días del mes

CREATE TABLE IF NOT EXISTS asistencia_datos_mes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  curso TEXT NOT NULL,
  seccion TEXT NOT NULL,
  mes TEXT NOT NULL,

  -- Datos en formato JSON
  -- {
  --   "asistencia": [
  --     ["", "", "", ...],  // Fila 1 (estudiante 1): 22 columnas
  --     ["", "", "", ...],  // Fila 2 (estudiante 2): 22 columnas
  --     ...                  // hasta 40 filas
  --   ],
  --   "feriados": {
  --     "5": "Día de la Constitución",
  --     "15": "Día de las Madres"
  --   },
  --   "diasMes": ["1", "2", "3", ..., "21"],
  --   "ultimaActualizacion": "2025-01-08T12:00:00Z"
  -- }
  datos JSONB NOT NULL,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Un usuario solo puede tener un registro de datos de asistencia por curso/sección/mes
  CONSTRAINT unique_user_curso_seccion_mes UNIQUE (user_id, curso, seccion, mes)
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_asistencia_datos_user_id ON asistencia_datos_mes(user_id);
CREATE INDEX IF NOT EXISTS idx_asistencia_datos_curso ON asistencia_datos_mes(curso);
CREATE INDEX IF NOT EXISTS idx_asistencia_datos_mes ON asistencia_datos_mes(mes);
CREATE INDEX IF NOT EXISTS idx_asistencia_datos_user_curso_mes ON asistencia_datos_mes(user_id, curso, seccion, mes);

-- Habilitar Row Level Security (RLS)
ALTER TABLE asistencia_datos_mes ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver sus propios datos
CREATE POLICY "Users can view own asistencia datos"
  ON asistencia_datos_mes
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden insertar sus propios datos
CREATE POLICY "Users can insert own asistencia datos"
  ON asistencia_datos_mes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden actualizar sus propios datos
CREATE POLICY "Users can update own asistencia datos"
  ON asistencia_datos_mes
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden eliminar sus propios datos
CREATE POLICY "Users can delete own asistencia datos"
  ON asistencia_datos_mes
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para actualizar updated_at en cada actualización
DROP TRIGGER IF EXISTS update_asistencia_datos_updated_at ON asistencia_datos_mes;
CREATE TRIGGER update_asistencia_datos_updated_at
    BEFORE UPDATE ON asistencia_datos_mes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios para documentación
COMMENT ON TABLE asistencia_datos_mes IS 'Almacena los datos completos de asistencia de un mes (matriz 40x22 + feriados + días)';
COMMENT ON COLUMN asistencia_datos_mes.user_id IS 'ID del usuario propietario de estos datos';
COMMENT ON COLUMN asistencia_datos_mes.curso IS 'Curso (Ej: 4to, 5to, etc.)';
COMMENT ON COLUMN asistencia_datos_mes.seccion IS 'Sección (Ej: A, B, etc.)';
COMMENT ON COLUMN asistencia_datos_mes.mes IS 'Mes (Ej: Enero, Febrero, etc.)';
COMMENT ON COLUMN asistencia_datos_mes.datos IS 'JSON con matriz de asistencia, feriados y días del mes';
