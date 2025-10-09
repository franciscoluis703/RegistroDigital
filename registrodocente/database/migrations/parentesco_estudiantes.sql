-- Tabla para guardar los datos de parentesco de estudiantes
-- Esta tabla almacena los datos de parentesco en formato tabla con 40 filas de estudiantes

CREATE TABLE IF NOT EXISTS parentesco_estudiantes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  curso_id TEXT NOT NULL,

  -- Datos en formato JSON
  -- {
  --   "parentescos": [
  --     {
  --       "padreNombre": "Juan Pérez",
  --       "padreTelefono": "809-555-1234",
  --       "madreNombre": "María García",
  --       "madreTelefono": "809-555-5678",
  --       "tutorNombre": "Pedro Martínez",
  --       "tutorTelefono": "809-555-9012"
  --     },  // Fila 1
  --     {
  --       "padreNombre": "Carlos López",
  --       "padreTelefono": "809-555-3456",
  --       "madreNombre": "Ana Rodríguez",
  --       "madreTelefono": "809-555-7890",
  --       "tutorNombre": "",
  --       "tutorTelefono": ""
  --     },  // Fila 2
  --     ...
  --   ]
  -- }
  datos JSONB NOT NULL,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Un usuario solo puede tener un registro de datos de parentesco por curso
  CONSTRAINT unique_user_curso_parentesco UNIQUE (user_id, curso_id)
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_parentesco_user_id ON parentesco_estudiantes(user_id);
CREATE INDEX IF NOT EXISTS idx_parentesco_curso_id ON parentesco_estudiantes(curso_id);
CREATE INDEX IF NOT EXISTS idx_parentesco_user_curso ON parentesco_estudiantes(user_id, curso_id);

-- Habilitar Row Level Security (RLS)
ALTER TABLE parentesco_estudiantes ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver sus propios datos
CREATE POLICY "Users can view own parentesco"
  ON parentesco_estudiantes
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden insertar sus propios datos
CREATE POLICY "Users can insert own parentesco"
  ON parentesco_estudiantes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden actualizar sus propios datos
CREATE POLICY "Users can update own parentesco"
  ON parentesco_estudiantes
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden eliminar sus propios datos
CREATE POLICY "Users can delete own parentesco"
  ON parentesco_estudiantes
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para actualizar updated_at en cada actualización
DROP TRIGGER IF EXISTS update_parentesco_estudiantes_updated_at ON parentesco_estudiantes;
CREATE TRIGGER update_parentesco_estudiantes_updated_at
    BEFORE UPDATE ON parentesco_estudiantes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios para documentación
COMMENT ON TABLE parentesco_estudiantes IS 'Almacena los datos de parentesco de estudiantes en formato tabla (40 filas)';
COMMENT ON COLUMN parentesco_estudiantes.user_id IS 'ID del usuario propietario de estos datos';
COMMENT ON COLUMN parentesco_estudiantes.curso_id IS 'ID del curso al que pertenecen estos datos';
COMMENT ON COLUMN parentesco_estudiantes.datos IS 'JSON con datos de parentesco organizados en filas (padre, madre y tutor con nombre y teléfono)';
