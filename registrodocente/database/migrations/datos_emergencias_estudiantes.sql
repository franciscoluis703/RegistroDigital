-- Tabla para guardar los datos de emergencias de estudiantes
-- Esta tabla almacena los datos de emergencias en formato tabla con 40 filas de estudiantes

CREATE TABLE IF NOT EXISTS datos_emergencias_estudiantes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  curso_id TEXT NOT NULL,

  -- Datos en formato JSON
  -- {
  --   "emergencias": [
  --     {
  --       "enfermedades": "Asma",
  --       "medicamentos": "Inhalador",
  --       "nombreApellido": "María García",
  --       "telefono": "809-555-1234",
  --       "parentesco": "Madre"
  --     },  // Fila 1
  --     {
  --       "enfermedades": "",
  --       "medicamentos": "",
  --       "nombreApellido": "Pedro Sánchez",
  --       "telefono": "809-555-5678",
  --       "parentesco": "Padre"
  --     },  // Fila 2
  --     ...
  --   ]
  -- }
  datos JSONB NOT NULL,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Un usuario solo puede tener un registro de datos de emergencias por curso
  CONSTRAINT unique_user_curso_emergencias UNIQUE (user_id, curso_id)
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_emergencias_user_id ON datos_emergencias_estudiantes(user_id);
CREATE INDEX IF NOT EXISTS idx_emergencias_curso_id ON datos_emergencias_estudiantes(curso_id);
CREATE INDEX IF NOT EXISTS idx_emergencias_user_curso ON datos_emergencias_estudiantes(user_id, curso_id);

-- Habilitar Row Level Security (RLS)
ALTER TABLE datos_emergencias_estudiantes ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver sus propios datos
CREATE POLICY "Users can view own emergencias"
  ON datos_emergencias_estudiantes
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden insertar sus propios datos
CREATE POLICY "Users can insert own emergencias"
  ON datos_emergencias_estudiantes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden actualizar sus propios datos
CREATE POLICY "Users can update own emergencias"
  ON datos_emergencias_estudiantes
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden eliminar sus propios datos
CREATE POLICY "Users can delete own emergencias"
  ON datos_emergencias_estudiantes
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para actualizar updated_at en cada actualización
DROP TRIGGER IF EXISTS update_datos_emergencias_estudiantes_updated_at ON datos_emergencias_estudiantes;
CREATE TRIGGER update_datos_emergencias_estudiantes_updated_at
    BEFORE UPDATE ON datos_emergencias_estudiantes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios para documentación
COMMENT ON TABLE datos_emergencias_estudiantes IS 'Almacena los datos de emergencias de estudiantes en formato tabla (40 filas)';
COMMENT ON COLUMN datos_emergencias_estudiantes.user_id IS 'ID del usuario propietario de estos datos';
COMMENT ON COLUMN datos_emergencias_estudiantes.curso_id IS 'ID del curso al que pertenecen estos datos';
COMMENT ON COLUMN datos_emergencias_estudiantes.datos IS 'JSON con datos de emergencias organizados en filas (enfermedades, medicamentos, contacto, teléfono, parentesco)';
