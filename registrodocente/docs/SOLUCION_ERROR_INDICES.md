# Solución al Error de Índices

## Error Encontrado
```
ERROR: 42P07: relation "idx_cursos_user_id" already exists
```

Este error ocurre porque algunos índices ya existen en tu base de datos.

## Solución en 2 Pasos

### Opción A: Script de Limpieza (Recomendado)

1. En Supabase SQL Editor, ejecuta primero el archivo `supabase_fix_indices.sql`
2. Espera a que termine (verás mensaje de confirmación)
3. Luego ejecuta el script principal `supabase_persistencia_completa.sql`

### Opción B: Modificar el Script Principal

Abre `supabase_persistencia_completa.sql` y reemplaza todas las líneas que dicen:

**ANTES:**
```sql
CREATE INDEX idx_cursos_user_id ON public.cursos(user_id);
```

**DESPUÉS:**
```sql
CREATE INDEX IF NOT EXISTS idx_cursos_user_id ON public.cursos(user_id);
```

Hacer esto para TODOS los índices en el archivo.

### Opción C: Ejecutar por Partes (Más Fácil)

Voy a crear scripts separados para que puedas ejecutarlos uno por uno sin errores.
