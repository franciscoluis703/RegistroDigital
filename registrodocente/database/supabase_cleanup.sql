-- =====================================================
-- SCRIPT DE LIMPIEZA COMPLETA
-- Elimina todas las tablas, funciones y triggers
-- =====================================================

-- IMPORTANTE: Este script ELIMINARÁ TODOS LOS DATOS
-- Solo ejecutar si quieres empezar desde cero

-- Eliminar triggers
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS update_cursos_updated_at ON public.cursos;
DROP TRIGGER IF EXISTS update_estudiantes_updated_at ON public.estudiantes;
DROP TRIGGER IF EXISTS update_asistencia_updated_at ON public.asistencia;
DROP TRIGGER IF EXISTS update_calificaciones_updated_at ON public.calificaciones;
DROP TRIGGER IF EXISTS update_promocion_grado_updated_at ON public.promocion_grado;
DROP TRIGGER IF EXISTS update_horarios_updated_at ON public.horarios;
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;

-- Eliminar funciones
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;

-- Eliminar tablas en orden correcto (respetando foreign keys)
DROP TABLE IF EXISTS public.sync_queue CASCADE;
DROP TABLE IF EXISTS public.user_activity_logs CASCADE;
DROP TABLE IF EXISTS public.horarios CASCADE;
DROP TABLE IF EXISTS public.promocion_grado CASCADE;
DROP TABLE IF EXISTS public.calificaciones CASCADE;
DROP TABLE IF EXISTS public.asistencia CASCADE;
DROP TABLE IF EXISTS public.estudiantes CASCADE;
DROP TABLE IF EXISTS public.cursos CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Mensaje de confirmación
SELECT 'Base de datos limpiada. Ahora ejecuta el script principal: supabase_persistencia_completa.sql' as mensaje;
