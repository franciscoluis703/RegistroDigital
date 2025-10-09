-- ============================================================================
-- SCRIPT PARA VERIFICAR QUÉ TABLAS EXISTEN EN SUPABASE
-- ============================================================================
-- Ejecuta este script en el SQL Editor de Supabase para ver todas las tablas
-- que existen en tu base de datos y cuáles faltan
-- ============================================================================

-- Ver todas las tablas en el esquema público
SELECT
    tablename as "Tabla",
    CASE
        WHEN tablename IN (
            'perfiles',
            'cursos',
            'estudiantes',
            'datos_generales_estudiantes',
            'condicion_inicial_estudiantes',
            'datos_emergencias_estudiantes',
            'parentesco_estudiantes',
            'asistencia_registros_meses',
            'asistencia_datos_mes',
            'calificaciones_notas_grupos',
            'nombres_grupos_calificaciones',
            'promocion_grado_datos',
            'evaluaciones_dias',
            'configuraciones_horario',
            'eventos_calendario',
            'datos_centro_educativo',
            'notas'
        ) THEN '✓ Necesaria'
        ELSE '? Adicional'
    END as "Estado",
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as "Tamaño"
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- ============================================================================
-- Verificar tablas faltantes
-- ============================================================================
SELECT
    tabla_necesaria as "Tabla Faltante"
FROM (
    VALUES
        ('perfiles'),
        ('cursos'),
        ('estudiantes'),
        ('datos_generales_estudiantes'),
        ('condicion_inicial_estudiantes'),
        ('datos_emergencias_estudiantes'),
        ('parentesco_estudiantes'),
        ('asistencia_registros_meses'),
        ('asistencia_datos_mes'),
        ('calificaciones_notas_grupos'),
        ('nombres_grupos_calificaciones'),
        ('promocion_grado_datos'),
        ('evaluaciones_dias'),
        ('configuraciones_horario'),
        ('eventos_calendario'),
        ('datos_centro_educativo'),
        ('notas')
) AS necesarias(tabla_necesaria)
WHERE NOT EXISTS (
    SELECT 1
    FROM pg_tables
    WHERE schemaname = 'public'
    AND tablename = necesarias.tabla_necesaria
)
ORDER BY tabla_necesaria;

-- ============================================================================
-- Ver columnas de las tablas de asistencia (si existen)
-- ============================================================================
SELECT
    table_name as "Tabla",
    column_name as "Columna",
    data_type as "Tipo",
    is_nullable as "Permite NULL"
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name IN ('asistencia_registros_meses', 'asistencia_datos_mes')
ORDER BY table_name, ordinal_position;
