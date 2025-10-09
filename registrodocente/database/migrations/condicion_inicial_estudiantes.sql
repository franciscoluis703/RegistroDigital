-- Tabla para guardar la condición inicial de estudiantes
-- Esta tabla almacena los datos de condición inicial en formato tabla con 40 filas de estudiantes

CREATE TABLE IF NOT EXISTS condicion_inicial_estudiantes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  curso_id TEXT NOT NULL,

  -- Datos en formato JSON
  -- {
  --   "condiciones": [
  --     {"correo": "email@example.com", "promovido": true, "repitente": false, "reingreso": false, "aplazado": false},  // Fila 1
  --     {"correo": "", "promovido": false, "repitente": true, "reingreso": false, "aplazado": false},  // Fila 2
  --     ...
  --   ]
  -- }
  datos JSONB NOT NULL,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Un usuario solo puede tener un registro de condición inicial por curso
  CONSTRAINT unique_user_curso_condicion_inicial UNIQUE (user_id, curso_id)
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_condicion_inicial_user_id ON condicion_inicial_estudiantes(user_id);
CREATE INDEX IF NOT EXISTS idx_condicion_inicial_curso_id ON condicion_inicial_estudiantes(curso_id);
CREATE INDEX IF NOT EXISTS idx_condicion_inicial_user_curso ON condicion_inicial_estudiantes(user_id, curso_id);

-- Habilitar Row Level Security (RLS)
ALTER TABLE condicion_inicial_estudiantes ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver sus propios datos
CREATE POLICY "Users can view own condicion inicial"
  ON condicion_inicial_estudiantes
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden insertar sus propios datos
CREATE POLICY "Users can insert own condicion inicial"
  ON condicion_inicial_estudiantes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden actualizar sus propios datos
CREATE POLICY "Users can update own condicion inicial"
  ON condicion_inicial_estudiantes
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden eliminar sus propios datos
CREATE POLICY "Users can delete own condicion inicial"
  ON condicion_inicial_estudiantes
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para actualizar updated_at en cada actualización
DROP TRIGGER IF EXISTS update_condicion_inicial_estudiantes_updated_at ON condicion_inicial_estudiantes;
CREATE TRIGGER update_condicion_inicial_estudiantes_updated_at
    BEFORE UPDATE ON condicion_inicial_estudiantes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios para documentación
COMMENT ON TABLE condicion_inicial_estudiantes IS 'Almacena la condición inicial de estudiantes en formato tabla (40 filas)';
COMMENT ON COLUMN condicion_inicial_estudiantes.user_id IS 'ID del usuario propietario de estos datos';
COMMENT ON COLUMN condicion_inicial_estudiantes.curso_id IS 'ID del curso al que pertenecen estos datos';
COMMENT ON COLUMN condicion_inicial_estudiantes.datos IS 'JSON con condiciones organizadas en filas (correo, promovido, repitente, reingreso, aplazado)';
