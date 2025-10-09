-- Eliminar tablas antiguas
DROP TABLE IF EXISTS public.notas CASCADE;
DROP TABLE IF EXISTS public.asistencia_datos_mes CASCADE;
DROP TABLE IF EXISTS public.asistencia_registros_meses CASCADE;
DROP TABLE IF EXISTS public.evaluaciones_dias CASCADE;
DROP TABLE IF EXISTS public.calificaciones_notas_grupos CASCADE;
DROP TABLE IF EXISTS public.nombres_grupos_calificaciones CASCADE;

-- Forzar reload del schema
NOTIFY pgrst, 'reload schema';

-- Crear tabla: notas
CREATE TABLE public.notas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    titulo TEXT NOT NULL,
    contenido TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.notas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own notes" ON public.notas FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own notes" ON public.notas FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own notes" ON public.notas FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own notes" ON public.notas FOR DELETE USING (auth.uid() = user_id);
GRANT ALL ON public.notas TO authenticated;

-- Crear tabla: asistencia_datos_mes
CREATE TABLE public.asistencia_datos_mes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    mes TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, curso, seccion, mes)
);

ALTER TABLE public.asistencia_datos_mes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view attendance" ON public.asistencia_datos_mes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert attendance" ON public.asistencia_datos_mes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update attendance" ON public.asistencia_datos_mes FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete attendance" ON public.asistencia_datos_mes FOR DELETE USING (auth.uid() = user_id);
GRANT ALL ON public.asistencia_datos_mes TO authenticated;

-- Crear tabla: asistencia_registros_meses
CREATE TABLE public.asistencia_registros_meses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, curso, seccion)
);

ALTER TABLE public.asistencia_registros_meses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view month records" ON public.asistencia_registros_meses FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert month records" ON public.asistencia_registros_meses FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update month records" ON public.asistencia_registros_meses FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete month records" ON public.asistencia_registros_meses FOR DELETE USING (auth.uid() = user_id);
GRANT ALL ON public.asistencia_registros_meses TO authenticated;

-- Crear tabla: evaluaciones_dias
CREATE TABLE public.evaluaciones_dias (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    curso_id TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, curso_id)
);

ALTER TABLE public.evaluaciones_dias ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view evaluations" ON public.evaluaciones_dias FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert evaluations" ON public.evaluaciones_dias FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update evaluations" ON public.evaluaciones_dias FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete evaluations" ON public.evaluaciones_dias FOR DELETE USING (auth.uid() = user_id);
GRANT ALL ON public.evaluaciones_dias TO authenticated;

-- Crear tabla: calificaciones_notas_grupos
CREATE TABLE public.calificaciones_notas_grupos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    datos JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, curso, seccion)
);

ALTER TABLE public.calificaciones_notas_grupos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view grades" ON public.calificaciones_notas_grupos FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert grades" ON public.calificaciones_notas_grupos FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update grades" ON public.calificaciones_notas_grupos FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete grades" ON public.calificaciones_notas_grupos FOR DELETE USING (auth.uid() = user_id);
GRANT ALL ON public.calificaciones_notas_grupos TO authenticated;

-- Crear tabla: nombres_grupos_calificaciones
CREATE TABLE public.nombres_grupos_calificaciones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    curso TEXT NOT NULL,
    seccion TEXT NOT NULL,
    nombres JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, curso, seccion)
);

ALTER TABLE public.nombres_grupos_calificaciones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view group names" ON public.nombres_grupos_calificaciones FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert group names" ON public.nombres_grupos_calificaciones FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update group names" ON public.nombres_grupos_calificaciones FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete group names" ON public.nombres_grupos_calificaciones FOR DELETE USING (auth.uid() = user_id);
GRANT ALL ON public.nombres_grupos_calificaciones TO authenticated;

-- Forzar reload final del schema
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';
