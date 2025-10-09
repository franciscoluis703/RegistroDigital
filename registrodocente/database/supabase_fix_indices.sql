-- =====================================================
-- FIX: Eliminar índices existentes antes de crearlos
-- Este script corrige el error de índices duplicados
-- =====================================================

-- Eliminar índices existentes si hay conflicto
DROP INDEX IF EXISTS public.idx_cursos_user_id;
DROP INDEX IF EXISTS public.idx_cursos_activo;
DROP INDEX IF EXISTS public.idx_estudiantes_user_id;
DROP INDEX IF EXISTS public.idx_estudiantes_curso_id;
DROP INDEX IF EXISTS public.idx_estudiantes_numero;
DROP INDEX IF EXISTS public.idx_asistencia_user_id;
DROP INDEX IF EXISTS public.idx_asistencia_curso_id;
DROP INDEX IF EXISTS public.idx_asistencia_estudiante_id;
DROP INDEX IF EXISTS public.idx_asistencia_fecha;
DROP INDEX IF EXISTS public.idx_asistencia_mes_año;
DROP INDEX IF EXISTS public.idx_calificaciones_user_id;
DROP INDEX IF EXISTS public.idx_calificaciones_curso_id;
DROP INDEX IF EXISTS public.idx_calificaciones_estudiante_id;
DROP INDEX IF EXISTS public.idx_calificaciones_periodo;
DROP INDEX IF EXISTS public.idx_promocion_user_id;
DROP INDEX IF EXISTS public.idx_promocion_curso_id;
DROP INDEX IF EXISTS public.idx_promocion_estudiante_id;
DROP INDEX IF EXISTS public.idx_horarios_user_id;
DROP INDEX IF EXISTS public.idx_horarios_curso_id;
DROP INDEX IF EXISTS public.idx_horarios_dia_semana;
DROP INDEX IF EXISTS public.idx_activity_logs_user_id;
DROP INDEX IF EXISTS public.idx_activity_logs_timestamp;
DROP INDEX IF EXISTS public.idx_activity_logs_action;
DROP INDEX IF EXISTS public.idx_activity_logs_entity_type;
DROP INDEX IF EXISTS public.idx_sync_queue_user_id;
DROP INDEX IF EXISTS public.idx_sync_queue_status;
DROP INDEX IF EXISTS public.idx_sync_queue_created_at;

-- Mensaje de confirmación
SELECT 'Índices eliminados correctamente. Ahora ejecuta el script principal nuevamente.' as mensaje;
