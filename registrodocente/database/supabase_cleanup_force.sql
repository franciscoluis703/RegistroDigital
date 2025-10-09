-- =====================================================
-- LIMPIEZA FORZADA - ELIMINA TODO
-- =====================================================

-- PASO 1: Eliminar TODOS los triggers en auth.users
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT trigger_name FROM information_schema.triggers
              WHERE event_object_schema = 'auth' AND event_object_table = 'users')
    LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || r.trigger_name || ' ON auth.users CASCADE';
    END LOOP;
END $$;

-- PASO 2: Eliminar todas las funciones del esquema public
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT routine_name FROM information_schema.routines
              WHERE routine_schema = 'public' AND routine_type = 'FUNCTION')
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS public.' || r.routine_name || ' CASCADE';
    END LOOP;
END $$;

-- PASO 3: Eliminar todas las tablas del esquema public
DROP TABLE IF EXISTS public.sync_queue CASCADE;
DROP TABLE IF EXISTS public.user_activity_logs CASCADE;
DROP TABLE IF EXISTS public.horarios CASCADE;
DROP TABLE IF EXISTS public.promocion_grado CASCADE;
DROP TABLE IF EXISTS public.calificaciones CASCADE;
DROP TABLE IF EXISTS public.asistencia CASCADE;
DROP TABLE IF EXISTS public.estudiantes CASCADE;
DROP TABLE IF EXISTS public.cursos CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- PASO 4: Eliminar todas las políticas RLS
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT schemaname, tablename, policyname
              FROM pg_policies WHERE schemaname = 'public')
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON ' || r.schemaname || '.' || r.tablename || ' CASCADE';
    END LOOP;
END $$;

SELECT '✅ Limpieza FORZADA completada. Ahora ejecuta supabase_persistencia_completa.sql' as resultado;
