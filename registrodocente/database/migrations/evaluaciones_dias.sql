-- Tabla para guardar las evaluaciones de días 1-10
-- Esta tabla almacena los datos de evaluaciones por días para 40 estudiantes

CREATE TABLE IF NOT EXISTS evaluaciones_dias (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  curso_id TEXT NOT NULL,

  -- Datos en formato JSON
  -- {
  --   "nombreDocente": "Nombre del Docente",
  --   "grado": "5to",
  --   "estudiantes": [
  --     {"1": "", "2": "", "3": "", ..., "10": ""},  // Estudiante 1: 10 días
  --     {"1": "", "2": "", "3": "", ..., "10": ""},  // Estudiante 2: 10 días
  --     ...                                          // hasta 40 estudiantes
  --   ],
  --   "ultimaActualizacion": "2025-01-08T12:00:00Z"
  -- }
  datos JSONB NOT NULL,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Un usuario solo puede tener un registro de evaluaciones por curso
  CONSTRAINT unique_user_curso_evaluaciones UNIQUE (user_id, curso_id)
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_evaluaciones_dias_user_id ON evaluaciones_dias(user_id);
CREATE INDEX IF NOT EXISTS idx_evaluaciones_dias_curso ON evaluaciones_dias(curso_id);
CREATE INDEX IF NOT EXISTS idx_evaluaciones_dias_user_curso ON evaluaciones_dias(user_id, curso_id);

-- Habilitar Row Level Security (RLS)
ALTER TABLE evaluaciones_dias ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver sus propios datos
CREATE POLICY "Users can view own evaluaciones dias"
  ON evaluaciones_dias
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden insertar sus propios datos
CREATE POLICY "Users can insert own evaluaciones dias"
  ON evaluaciones_dias
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden actualizar sus propios datos
CREATE POLICY "Users can update own evaluaciones dias"
  ON evaluaciones_dias
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden eliminar sus propios datos
CREATE POLICY "Users can delete own evaluaciones dias"
  ON evaluaciones_dias
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para actualizar updated_at en cada actualización
DROP TRIGGER IF EXISTS update_evaluaciones_dias_updated_at ON evaluaciones_dias;
CREATE TRIGGER update_evaluaciones_dias_updated_at
    BEFORE UPDATE ON evaluaciones_dias
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios para documentación
COMMENT ON TABLE evaluaciones_dias IS 'Almacena las evaluaciones de 10 días para 40 estudiantes';
COMMENT ON COLUMN evaluaciones_dias.user_id IS 'ID del usuario propietario de estos datos';
COMMENT ON COLUMN evaluaciones_dias.curso_id IS 'ID del curso (grado_seccion_asignatura)';
COMMENT ON COLUMN evaluaciones_dias.datos IS 'JSON con nombreDocente, grado y matriz de evaluaciones (40 estudiantes x 10 días)';
