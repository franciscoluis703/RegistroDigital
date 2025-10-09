-- Tabla para guardar las notas de los 4 grupos de calificaciones
-- Esta tabla almacena las matrices de calificaciones de 40 estudiantes x 8 columnas por grupo

CREATE TABLE IF NOT EXISTS calificaciones_notas_grupos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  curso TEXT NOT NULL,
  seccion TEXT NOT NULL,

  -- Datos en formato JSON
  -- {
  --   "grupo1": [
  --     ["", "", "", "", "", "", "", ""],  // Fila 1 (estudiante 1): 8 columnas
  --     ["", "", "", "", "", "", "", ""],  // Fila 2 (estudiante 2): 8 columnas
  --     ...                                // hasta 40 filas
  --   ],
  --   "grupo2": [...],  // Igual que grupo1
  --   "grupo3": [...],  // Igual que grupo1
  --   "grupo4": [...],  // Igual que grupo1
  --   "ultimaActualizacion": "2025-01-08T12:00:00Z"
  -- }
  datos JSONB NOT NULL,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Un usuario solo puede tener un registro de notas por curso/sección
  CONSTRAINT unique_user_curso_seccion_notas UNIQUE (user_id, curso, seccion)
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_calificaciones_notas_user_id ON calificaciones_notas_grupos(user_id);
CREATE INDEX IF NOT EXISTS idx_calificaciones_notas_curso ON calificaciones_notas_grupos(curso);
CREATE INDEX IF NOT EXISTS idx_calificaciones_notas_user_curso ON calificaciones_notas_grupos(user_id, curso, seccion);

-- Habilitar Row Level Security (RLS)
ALTER TABLE calificaciones_notas_grupos ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver sus propios datos
CREATE POLICY "Users can view own calificaciones notas"
  ON calificaciones_notas_grupos
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden insertar sus propios datos
CREATE POLICY "Users can insert own calificaciones notas"
  ON calificaciones_notas_grupos
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden actualizar sus propios datos
CREATE POLICY "Users can update own calificaciones notas"
  ON calificaciones_notas_grupos
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden eliminar sus propios datos
CREATE POLICY "Users can delete own calificaciones notas"
  ON calificaciones_notas_grupos
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para actualizar updated_at en cada actualización
DROP TRIGGER IF EXISTS update_calificaciones_notas_updated_at ON calificaciones_notas_grupos;
CREATE TRIGGER update_calificaciones_notas_updated_at
    BEFORE UPDATE ON calificaciones_notas_grupos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios para documentación
COMMENT ON TABLE calificaciones_notas_grupos IS 'Almacena las notas de los 4 grupos (40 estudiantes x 8 columnas por grupo)';
COMMENT ON COLUMN calificaciones_notas_grupos.user_id IS 'ID del usuario propietario de estos datos';
COMMENT ON COLUMN calificaciones_notas_grupos.curso IS 'Curso (Ej: 4to, 5to, etc.)';
COMMENT ON COLUMN calificaciones_notas_grupos.seccion IS 'Sección (Ej: A, B, etc.)';
COMMENT ON COLUMN calificaciones_notas_grupos.datos IS 'JSON con las 4 matrices de notas (grupo1, grupo2, grupo3, grupo4)';
