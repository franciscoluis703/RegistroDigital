-- ============================================
-- ESQUEMA DE BASE DE DATOS PARA REGISTRO DOCENTE
-- ============================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLA: docentes
-- Información del docente que usa la aplicación
-- ============================================
CREATE TABLE IF NOT EXISTS docentes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  nombre VARCHAR(255) NOT NULL,
  apellido VARCHAR(255) NOT NULL,
  cedula VARCHAR(20) UNIQUE,
  email VARCHAR(255) UNIQUE NOT NULL,
  telefono VARCHAR(20),
  centro_educativo VARCHAR(255),
  regional VARCHAR(50),
  distrito VARCHAR(50),
  foto_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- ============================================
-- TABLA: cursos
-- Cursos que imparte el docente
-- ============================================
CREATE TABLE IF NOT EXISTS cursos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  nombre VARCHAR(255) NOT NULL,
  asignatura VARCHAR(255) NOT NULL,
  secciones JSONB DEFAULT '["A"]'::jsonb,
  oculto BOOLEAN DEFAULT FALSE,
  activo BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TABLA: estudiantes
-- Estudiantes de cada curso
-- ============================================
CREATE TABLE IF NOT EXISTS estudiantes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  curso_id UUID REFERENCES cursos(id) ON DELETE CASCADE,
  seccion VARCHAR(10) NOT NULL,
  numero INTEGER NOT NULL,
  nombre VARCHAR(255) NOT NULL,
  sexo VARCHAR(1),
  fecha_nacimiento DATE,
  acta_nacimiento JSONB,
  cedula_pasaporte VARCHAR(50),
  rne VARCHAR(50),
  direccion TEXT,
  foto_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TABLA: asistencias
-- Registro de asistencias por fecha
-- ============================================
CREATE TABLE IF NOT EXISTS asistencias (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  estudiante_id UUID REFERENCES estudiantes(id) ON DELETE CASCADE,
  curso_id UUID REFERENCES cursos(id) ON DELETE CASCADE,
  fecha DATE NOT NULL,
  presente BOOLEAN NOT NULL DEFAULT TRUE,
  justificado BOOLEAN DEFAULT FALSE,
  observaciones TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(estudiante_id, fecha)
);

-- ============================================
-- TABLA: calificaciones
-- Calificaciones de los estudiantes
-- ============================================
CREATE TABLE IF NOT EXISTS calificaciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  estudiante_id UUID REFERENCES estudiantes(id) ON DELETE CASCADE,
  curso_id UUID REFERENCES cursos(id) ON DELETE CASCADE,
  periodo VARCHAR(50) NOT NULL,
  competencia VARCHAR(255) NOT NULL,
  calificacion DECIMAL(5,2),
  literal VARCHAR(5),
  observaciones TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TABLA: evaluaciones
-- Evaluaciones y exámenes
-- ============================================
CREATE TABLE IF NOT EXISTS evaluaciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  curso_id UUID REFERENCES cursos(id) ON DELETE CASCADE,
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  fecha DATE NOT NULL,
  ponderacion DECIMAL(5,2),
  tipo VARCHAR(50),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TABLA: datos_emergencia
-- Datos para emergencias de estudiantes
-- ============================================
CREATE TABLE IF NOT EXISTS datos_emergencia (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  estudiante_id UUID REFERENCES estudiantes(id) ON DELETE CASCADE,
  contacto_nombre VARCHAR(255),
  contacto_telefono VARCHAR(20),
  contacto_relacion VARCHAR(100),
  tipo_sangre VARCHAR(5),
  alergias TEXT,
  condiciones_medicas TEXT,
  medicamentos TEXT,
  seguro_medico VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(estudiante_id)
);

-- ============================================
-- TABLA: parentesco
-- Información de padres/tutores
-- ============================================
CREATE TABLE IF NOT EXISTS parentesco (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  estudiante_id UUID REFERENCES estudiantes(id) ON DELETE CASCADE,
  tipo VARCHAR(50) NOT NULL,
  nombre VARCHAR(255) NOT NULL,
  cedula VARCHAR(20),
  telefono VARCHAR(20),
  ocupacion VARCHAR(255),
  lugar_trabajo VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ÍNDICES PARA MEJORAR RENDIMIENTO
-- ============================================
CREATE INDEX idx_cursos_user_id ON cursos(user_id);
CREATE INDEX idx_estudiantes_curso_id ON estudiantes(curso_id);
CREATE INDEX idx_asistencias_estudiante_id ON asistencias(estudiante_id);
CREATE INDEX idx_asistencias_fecha ON asistencias(fecha);
CREATE INDEX idx_calificaciones_estudiante_id ON calificaciones(estudiante_id);
CREATE INDEX idx_evaluaciones_curso_id ON evaluaciones(curso_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- Cada docente solo ve sus propios datos
-- ============================================

-- Habilitar RLS en todas las tablas
ALTER TABLE docentes ENABLE ROW LEVEL SECURITY;
ALTER TABLE cursos ENABLE ROW LEVEL SECURITY;
ALTER TABLE estudiantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE asistencias ENABLE ROW LEVEL SECURITY;
ALTER TABLE calificaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE evaluaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE datos_emergencia ENABLE ROW LEVEL SECURITY;
ALTER TABLE parentesco ENABLE ROW LEVEL SECURITY;

-- Políticas para DOCENTES
CREATE POLICY "Docentes pueden ver sus propios datos"
  ON docentes FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Docentes pueden actualizar sus propios datos"
  ON docentes FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Docentes pueden insertar sus propios datos"
  ON docentes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Políticas para CURSOS
CREATE POLICY "Usuarios pueden ver sus propios cursos"
  ON cursos FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden crear sus propios cursos"
  ON cursos FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden actualizar sus propios cursos"
  ON cursos FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden eliminar sus propios cursos"
  ON cursos FOR DELETE
  USING (auth.uid() = user_id);

-- Políticas para ESTUDIANTES
CREATE POLICY "Usuarios pueden ver estudiantes de sus cursos"
  ON estudiantes FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM cursos
      WHERE cursos.id = estudiantes.curso_id
      AND cursos.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuarios pueden crear estudiantes en sus cursos"
  ON estudiantes FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM cursos
      WHERE cursos.id = estudiantes.curso_id
      AND cursos.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuarios pueden actualizar estudiantes de sus cursos"
  ON estudiantes FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM cursos
      WHERE cursos.id = estudiantes.curso_id
      AND cursos.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuarios pueden eliminar estudiantes de sus cursos"
  ON estudiantes FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM cursos
      WHERE cursos.id = estudiantes.curso_id
      AND cursos.user_id = auth.uid()
    )
  );

-- Políticas para ASISTENCIAS
CREATE POLICY "Usuarios pueden ver asistencias de sus estudiantes"
  ON asistencias FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM estudiantes
      JOIN cursos ON cursos.id = estudiantes.curso_id
      WHERE estudiantes.id = asistencias.estudiante_id
      AND cursos.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuarios pueden crear asistencias para sus estudiantes"
  ON asistencias FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM estudiantes
      JOIN cursos ON cursos.id = estudiantes.curso_id
      WHERE estudiantes.id = asistencias.estudiante_id
      AND cursos.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuarios pueden actualizar asistencias de sus estudiantes"
  ON asistencias FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM estudiantes
      JOIN cursos ON cursos.id = estudiantes.curso_id
      WHERE estudiantes.id = asistencias.estudiante_id
      AND cursos.user_id = auth.uid()
    )
  );

-- Políticas para CALIFICACIONES (similar a asistencias)
CREATE POLICY "Usuarios pueden ver calificaciones de sus estudiantes"
  ON calificaciones FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM estudiantes
      JOIN cursos ON cursos.id = estudiantes.curso_id
      WHERE estudiantes.id = calificaciones.estudiante_id
      AND cursos.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuarios pueden crear calificaciones para sus estudiantes"
  ON calificaciones FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM estudiantes
      JOIN cursos ON cursos.id = estudiantes.curso_id
      WHERE estudiantes.id = calificaciones.estudiante_id
      AND cursos.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuarios pueden actualizar calificaciones de sus estudiantes"
  ON calificaciones FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM estudiantes
      JOIN cursos ON cursos.id = estudiantes.curso_id
      WHERE estudiantes.id = calificaciones.estudiante_id
      AND cursos.user_id = auth.uid()
    )
  );

-- Políticas para EVALUACIONES
CREATE POLICY "Usuarios pueden ver evaluaciones de sus cursos"
  ON evaluaciones FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM cursos
      WHERE cursos.id = evaluaciones.curso_id
      AND cursos.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuarios pueden crear evaluaciones en sus cursos"
  ON evaluaciones FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM cursos
      WHERE cursos.id = evaluaciones.curso_id
      AND cursos.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuarios pueden actualizar evaluaciones de sus cursos"
  ON evaluaciones FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM cursos
      WHERE cursos.id = evaluaciones.curso_id
      AND cursos.user_id = auth.uid()
    )
  );

-- Políticas para DATOS_EMERGENCIA
CREATE POLICY "Usuarios pueden ver datos emergencia de sus estudiantes"
  ON datos_emergencia FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM estudiantes
      JOIN cursos ON cursos.id = estudiantes.curso_id
      WHERE estudiantes.id = datos_emergencia.estudiante_id
      AND cursos.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuarios pueden crear datos emergencia para sus estudiantes"
  ON datos_emergencia FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM estudiantes
      JOIN cursos ON cursos.id = estudiantes.curso_id
      WHERE estudiantes.id = datos_emergencia.estudiante_id
      AND cursos.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuarios pueden actualizar datos emergencia de sus estudiantes"
  ON datos_emergencia FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM estudiantes
      JOIN cursos ON cursos.id = estudiantes.curso_id
      WHERE estudiantes.id = datos_emergencia.estudiante_id
      AND cursos.user_id = auth.uid()
    )
  );

-- Políticas para PARENTESCO
CREATE POLICY "Usuarios pueden ver parentesco de sus estudiantes"
  ON parentesco FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM estudiantes
      JOIN cursos ON cursos.id = estudiantes.curso_id
      WHERE estudiantes.id = parentesco.estudiante_id
      AND cursos.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuarios pueden crear parentesco para sus estudiantes"
  ON parentesco FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM estudiantes
      JOIN cursos ON cursos.id = estudiantes.curso_id
      WHERE estudiantes.id = parentesco.estudiante_id
      AND cursos.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuarios pueden actualizar parentesco de sus estudiantes"
  ON parentesco FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM estudiantes
      JOIN cursos ON cursos.id = estudiantes.curso_id
      WHERE estudiantes.id = parentesco.estudiante_id
      AND cursos.user_id = auth.uid()
    )
  );

-- ============================================
-- TRIGGERS PARA UPDATED_AT
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_docentes_updated_at BEFORE UPDATE ON docentes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cursos_updated_at BEFORE UPDATE ON cursos
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_estudiantes_updated_at BEFORE UPDATE ON estudiantes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_asistencias_updated_at BEFORE UPDATE ON asistencias
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_calificaciones_updated_at BEFORE UPDATE ON calificaciones
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
