-- Tabla para guardar los datos del centro educativo
-- Esta tabla almacena la información completa del centro educativo del usuario

CREATE TABLE IF NOT EXISTS datos_centro_educativo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Datos básicos del centro
  nombre_centro TEXT,
  direccion TEXT,
  correo TEXT,
  telefono_centro TEXT,
  codigo_gestion TEXT,
  codigo_cartografia TEXT,

  -- Datos del director
  director_nombre TEXT,
  director_correo TEXT,
  director_telefono TEXT,

  -- Datos del docente encargado
  docente_nombre TEXT,
  docente_correo TEXT,
  docente_telefono TEXT,

  -- Ubicación y características
  regional TEXT,
  distrito TEXT,
  sector TEXT, -- Público, Privado, Semioficial
  zona TEXT, -- Urbana, Urbana marginal, Urbana turística, Rural, Rural aislada, Rural turística
  jornada TEXT, -- Jee, Matutina, Vespertina, Nocturna

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Un usuario solo puede tener un registro de centro educativo
  CONSTRAINT unique_user_centro UNIQUE (user_id)
);

-- Índice para búsquedas rápidas por usuario
CREATE INDEX IF NOT EXISTS idx_datos_centro_user_id ON datos_centro_educativo(user_id);

-- Habilitar Row Level Security (RLS)
ALTER TABLE datos_centro_educativo ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver sus propios datos
CREATE POLICY "Users can view own centro data"
  ON datos_centro_educativo
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden insertar sus propios datos
CREATE POLICY "Users can insert own centro data"
  ON datos_centro_educativo
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden actualizar sus propios datos
CREATE POLICY "Users can update own centro data"
  ON datos_centro_educativo
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden eliminar sus propios datos
CREATE POLICY "Users can delete own centro data"
  ON datos_centro_educativo
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para actualizar updated_at en cada actualización
DROP TRIGGER IF EXISTS update_datos_centro_updated_at ON datos_centro_educativo;
CREATE TRIGGER update_datos_centro_updated_at
    BEFORE UPDATE ON datos_centro_educativo
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios para documentación
COMMENT ON TABLE datos_centro_educativo IS 'Almacena los datos completos del centro educativo de cada usuario';
COMMENT ON COLUMN datos_centro_educativo.user_id IS 'ID del usuario propietario de estos datos';
COMMENT ON COLUMN datos_centro_educativo.nombre_centro IS 'Nombre oficial del centro educativo';
COMMENT ON COLUMN datos_centro_educativo.codigo_gestion IS 'Código de gestión SIGERD del centro';
COMMENT ON COLUMN datos_centro_educativo.codigo_cartografia IS 'Código de cartografía del centro';
COMMENT ON COLUMN datos_centro_educativo.sector IS 'Público, Privado o Semioficial';
COMMENT ON COLUMN datos_centro_educativo.zona IS 'Tipo de zona donde se encuentra el centro';
COMMENT ON COLUMN datos_centro_educativo.jornada IS 'Tipo de jornada del centro';
