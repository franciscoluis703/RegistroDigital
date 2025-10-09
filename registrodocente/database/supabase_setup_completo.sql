-- ============================================
-- SETUP COMPLETO - REGISTRO DOCENTE
-- Ejecutar todo este script en SQL Editor
-- ============================================

-- 1. TABLA DE PERFILES
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

ALTER TABLE perfiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios gestionan su perfil" ON perfiles FOR ALL USING (auth.uid() = id);

-- 2. TABLA DE CURSOS
CREATE TABLE IF NOT EXISTS cursos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  nombre TEXT NOT NULL,
  asignatura TEXT NOT NULL,
  grado TEXT,
  secciones JSONB DEFAULT '["A"]'::jsonb,
  oculto BOOLEAN DEFAULT false,
  activo BOOLEAN DEFAULT false,
  color TEXT,
  descripcion TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cursos_user_id ON cursos(user_id);
ALTER TABLE cursos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios gestionan sus cursos" ON cursos FOR ALL USING (auth.uid() = user_id);

-- 3. TABLA DE ESTUDIANTES
CREATE TABLE IF NOT EXISTS estudiantes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  curso_id UUID REFERENCES cursos(id) ON DELETE CASCADE NOT NULL,
  nombre TEXT NOT NULL,
  apellido TEXT,
  sexo TEXT CHECK (sexo IN ('masculino', 'femenino')),
  fecha_nacimiento DATE,
  edad INTEGER,
  cedula TEXT,
  rne TEXT,
  lugar_residencia TEXT,
  provincia TEXT,
  municipio TEXT,
  sector TEXT,
  correo_electronico TEXT,
  telefono TEXT,
  centro_educativo TEXT,
  regional TEXT,
  distrito TEXT,
  repite_grado BOOLEAN DEFAULT false,
  nuevo_ingreso BOOLEAN DEFAULT false,
  promovido BOOLEAN DEFAULT false,
  contacto_emergencia_nombre TEXT,
  contacto_emergencia_telefono TEXT,
  contacto_emergencia_parentesco TEXT,
  seccion TEXT,
  numero_orden INTEGER,
  foto_url TEXT,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_estudiantes_curso_id ON estudiantes(curso_id);
ALTER TABLE estudiantes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios gestionan estudiantes de sus cursos" ON estudiantes FOR ALL 
USING (EXISTS (SELECT 1 FROM cursos WHERE cursos.id = estudiantes.curso_id AND cursos.user_id = auth.uid()));

-- 4. TABLA DE ASISTENCIAS
CREATE TABLE IF NOT EXISTS asistencias (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  curso_id UUID REFERENCES cursos(id) ON DELETE CASCADE NOT NULL,
  estudiante_id UUID REFERENCES estudiantes(id) ON DELETE CASCADE NOT NULL,
  fecha DATE NOT NULL,
  mes TEXT NOT NULL,
  anio INTEGER NOT NULL,
  estado TEXT CHECK (estado IN ('presente', 'ausente', 'tardanza', 'justificado', 'feriado')) NOT NULL,
  seccion TEXT,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(curso_id, estudiante_id, fecha)
);

CREATE INDEX IF NOT EXISTS idx_asistencias_curso_id ON asistencias(curso_id);
ALTER TABLE asistencias ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios gestionan asistencias de sus cursos" ON asistencias FOR ALL 
USING (EXISTS (SELECT 1 FROM cursos WHERE cursos.id = asistencias.curso_id AND cursos.user_id = auth.uid()));

-- 5. TABLA DE REGISTROS DE ASISTENCIA
CREATE TABLE IF NOT EXISTS asistencia_registros (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  curso_id UUID REFERENCES cursos(id) ON DELETE CASCADE NOT NULL,
  mes TEXT NOT NULL,
  anio INTEGER NOT NULL,
  seccion TEXT NOT NULL,
  dias_mes JSONB DEFAULT '[]'::jsonb,
  feriados JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(curso_id, mes, anio, seccion)
);

CREATE INDEX IF NOT EXISTS idx_asistencia_registros_curso_id ON asistencia_registros(curso_id);
ALTER TABLE asistencia_registros ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios gestionan registros de asistencia de sus cursos" ON asistencia_registros FOR ALL 
USING (EXISTS (SELECT 1 FROM cursos WHERE cursos.id = asistencia_registros.curso_id AND cursos.user_id = auth.uid()));

-- 6. TABLA DE CALIFICACIONES
CREATE TABLE IF NOT EXISTS calificaciones (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  curso_id UUID REFERENCES cursos(id) ON DELETE CASCADE NOT NULL,
  estudiante_id UUID REFERENCES estudiantes(id) ON DELETE CASCADE NOT NULL,
  periodo TEXT NOT NULL,
  competencia_1 NUMERIC(5,2),
  competencia_2 NUMERIC(5,2),
  competencia_3 NUMERIC(5,2),
  competencia_4 NUMERIC(5,2),
  competencia_5 NUMERIC(5,2),
  competencia_6 NUMERIC(5,2),
  competencia_7 NUMERIC(5,2),
  competencia_8 NUMERIC(5,2),
  competencia_9 NUMERIC(5,2),
  competencia_10 NUMERIC(5,2),
  calificacion_final NUMERIC(5,2),
  seccion TEXT,
  observaciones TEXT,
  fecha_carga TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(curso_id, estudiante_id, periodo, seccion)
);

CREATE INDEX IF NOT EXISTS idx_calificaciones_curso_id ON calificaciones(curso_id);
ALTER TABLE calificaciones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios gestionan calificaciones de sus cursos" ON calificaciones FOR ALL 
USING (EXISTS (SELECT 1 FROM cursos WHERE cursos.id = calificaciones.curso_id AND cursos.user_id = auth.uid()));

-- 7. TABLA DE PROMOCIÓN DE GRADO
CREATE TABLE IF NOT EXISTS promocion_grado (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  curso_id UUID REFERENCES cursos(id) ON DELETE CASCADE NOT NULL,
  estudiante_id UUID REFERENCES estudiantes(id) ON DELETE CASCADE NOT NULL,
  numero_orden INTEGER,
  calificacion_grupo_1 NUMERIC(5,2),
  calificacion_grupo_2 NUMERIC(5,2),
  calificacion_grupo_3 NUMERIC(5,2),
  calificacion_grupo_4 NUMERIC(5,2),
  promedio_final NUMERIC(5,2),
  estado_promocion TEXT CHECK (estado_promocion IN ('promovido', 'reprobado', 'pendiente')),
  asignatura TEXT,
  grado TEXT,
  seccion TEXT,
  anio_escolar TEXT,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(curso_id, estudiante_id, anio_escolar)
);

CREATE INDEX IF NOT EXISTS idx_promocion_grado_curso_id ON promocion_grado(curso_id);
ALTER TABLE promocion_grado ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios gestionan promoción de sus cursos" ON promocion_grado FOR ALL 
USING (EXISTS (SELECT 1 FROM cursos WHERE cursos.id = promocion_grado.curso_id AND cursos.user_id = auth.uid()));

-- 8. TABLA DE HORARIOS
CREATE TABLE IF NOT EXISTS horarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  curso_id UUID REFERENCES cursos(id) ON DELETE CASCADE,
  dia_semana TEXT CHECK (dia_semana IN ('lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo')) NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME NOT NULL,
  asignatura TEXT,
  aula TEXT,
  seccion TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_horarios_user_id ON horarios(user_id);
ALTER TABLE horarios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios gestionan sus horarios" ON horarios FOR ALL USING (auth.uid() = user_id);

-- 9. TABLA DE EVENTOS DE CALENDARIO
CREATE TABLE IF NOT EXISTS eventos_calendario (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  titulo TEXT NOT NULL,
  descripcion TEXT,
  fecha DATE NOT NULL,
  hora_inicio TIME,
  hora_fin TIME,
  tipo TEXT CHECK (tipo IN ('feriado', 'reunion', 'evaluacion', 'actividad', 'otro')),
  color TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_eventos_user_id ON eventos_calendario(user_id);
ALTER TABLE eventos_calendario ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios gestionan sus eventos" ON eventos_calendario FOR ALL USING (auth.uid() = user_id);

-- 10. FUNCIÓN PARA CREAR PERFIL AUTOMÁTICAMENTE
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.perfiles (id, nombre, email)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'nombre', 'Usuario'), NEW.email)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- VERIFICACIÓN FINAL
SELECT 'Setup completado! Tablas creadas:' as mensaje;
SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;
