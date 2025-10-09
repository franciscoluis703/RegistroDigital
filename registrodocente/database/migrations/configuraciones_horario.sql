-- Tabla para guardar las configuraciones completas del horario de clase
-- Esta tabla almacena la configuración JSON del horario de cada usuario

CREATE TABLE IF NOT EXISTS configuraciones_horario (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  configuracion TEXT NOT NULL, -- JSON con la configuración completa del horario
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Un usuario solo puede tener una configuración de horario
  CONSTRAINT unique_user_horario UNIQUE (user_id)
);

-- Índice para búsquedas rápidas por usuario
CREATE INDEX IF NOT EXISTS idx_configuraciones_horario_user_id ON configuraciones_horario(user_id);

-- Habilitar Row Level Security (RLS)
ALTER TABLE configuraciones_horario ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver su propia configuración
CREATE POLICY "Users can view own horario configuration"
  ON configuraciones_horario
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden insertar su propia configuración
CREATE POLICY "Users can insert own horario configuration"
  ON configuraciones_horario
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden actualizar su propia configuración
CREATE POLICY "Users can update own horario configuration"
  ON configuraciones_horario
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden eliminar su propia configuración
CREATE POLICY "Users can delete own horario configuration"
  ON configuraciones_horario
  FOR DELETE
  USING (auth.uid() = user_id);

-- Función para actualizar el campo updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar updated_at en cada actualización
DROP TRIGGER IF EXISTS update_configuraciones_horario_updated_at ON configuraciones_horario;
CREATE TRIGGER update_configuraciones_horario_updated_at
    BEFORE UPDATE ON configuraciones_horario
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios para documentación
COMMENT ON TABLE configuraciones_horario IS 'Almacena las configuraciones completas del horario de clase de cada usuario';
COMMENT ON COLUMN configuraciones_horario.configuracion IS 'JSON con la estructura completa del horario: períodos, horarios, materias, colores, etc.';
COMMENT ON COLUMN configuraciones_horario.user_id IS 'ID del usuario propietario de esta configuración de horario';
