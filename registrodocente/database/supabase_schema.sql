-- ============================================
-- SCHEMA COMPLETO PARA REGISTRO DOCENTE
-- Base de datos Supabase
-- ============================================

-- ============================================
-- 1. TABLA DE PERFILES DE USUARIO
-- ============================================
CREATE TABLE IF NOT EXISTS perfiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  nombre TEXT NOT NULL,
  email TEXT,
  foto_perfil TEXT,
  genero TEXT CHECK (genero IN ('masculino', 'femenino', 'otro')),
  centro_educativo TEXT DEFAULT 'Centro Educativo Eugenio M. de Hostos',
  regional TEXT DEFAULT '17',
  distrito TEXT DEFAULT '04',
  telefono TEXT,
  direccion TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para perfiles
CREATE INDEX IF NOT EXISTS idx_perfiles_email ON perfiles(email);

-- RLS para perfiles
ALTER TABLE perfiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver su propio perfil"
  ON perfiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Los usuarios pueden actualizar su propio perfil"
  ON perfiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Los usuarios pueden insertar su propio perfil"
  ON perfiles FOR INSERT
  WITH CHECK (auth.uid() = id);
