# Migraciones de Base de Datos - Supabase

Este directorio contiene las migraciones SQL para la base de datos de Supabase.

## Tablas Disponibles

1. **`configuraciones_horario`** - Configuración completa del horario de clase
2. **`datos_centro_educativo`** - Datos del centro educativo del usuario
3. **`datos_generales_estudiantes`** - Datos generales de estudiantes (tabla de 40 filas)
4. **`condicion_inicial_estudiantes`** - Condición inicial de estudiantes (tabla de 40 filas)
5. **`datos_emergencias_estudiantes`** - Datos de emergencias de estudiantes (tabla de 40 filas)
6. **`parentesco_estudiantes`** - Datos de parentesco de estudiantes (tabla de 40 filas)
7. **`asistencia_registros_meses`** - Registros de meses de asistencia (lista de 10 meses)
8. **`asistencia_datos_mes`** - Datos completos de asistencia por mes (matriz 40x22)
9. **`calificaciones_notas_grupos`** - Notas de los 4 grupos de calificaciones (4 matrices de 40x8)
10. **`promocion_grado_datos`** - Datos de promoción del grado (matriz con datos completos)
11. **`evaluaciones_dias`** - Evaluaciones de 10 días (matriz 40 estudiantes x 10 días)

---

## Configuración de la tabla `configuraciones_horario`

La tabla `configuraciones_horario` almacena la configuración completa del horario de clase de cada usuario, incluyendo:
- Períodos del día
- Horarios de inicio y fin
- Materias por día
- Colores de identificación
- Configuración de recreo/almuerzo
- Alarmas configuradas

### Cómo ejecutar la migración

#### Opción 1: Desde la interfaz de Supabase (Recomendado)

1. Ve a [Supabase Dashboard](https://supabase.com/dashboard)
2. Selecciona tu proyecto
3. Ve a **SQL Editor** en el menú lateral
4. Haz clic en **New query**
5. Copia y pega el contenido del archivo `migrations/configuraciones_horario.sql`
6. Haz clic en **Run** (o presiona `Ctrl/Cmd + Enter`)

#### Opción 2: Usando Supabase CLI

```bash
# Si aún no has instalado Supabase CLI
npm install -g supabase

# Desde la raíz del proyecto
supabase db reset  # Esto ejecutará todas las migraciones

# O ejecutar una migración específica
supabase db execute -f database/migrations/configuraciones_horario.sql
```

### Verificar que la tabla se creó correctamente

Ejecuta esta consulta en el SQL Editor:

```sql
SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'configuraciones_horario';
```

Deberías ver las columnas:
- `id` (uuid)
- `user_id` (uuid)
- `configuracion` (text)
- `created_at` (timestamp with time zone)
- `updated_at` (timestamp with time zone)

### Políticas de Seguridad (RLS)

La tabla tiene Row Level Security (RLS) habilitado con las siguientes políticas:

- **SELECT**: Los usuarios solo pueden ver su propia configuración
- **INSERT**: Los usuarios solo pueden crear su propia configuración
- **UPDATE**: Los usuarios solo pueden actualizar su propia configuración
- **DELETE**: Los usuarios solo pueden eliminar su propia configuración

### Estructura del JSON almacenado

El campo `configuracion` almacena un JSON con la siguiente estructura:

```json
[
  {
    "numero": 1,
    "horaInicio": "8:00 AM",
    "horaFin": "8:45 AM",
    "materias": ["Matemática", "Español", "", "", ""],
    "colores": [4294198070, null, null, null, null],
    "esRecreo": false,
    "esAlmuerzo": false,
    "nombre": "",
    "alarmaActiva": false
  },
  {
    "numero": 2,
    "horaInicio": "8:45 AM",
    "horaFin": "9:30 AM",
    "materias": ["", "", "", "", ""],
    "colores": [null, null, null, null, null],
    "esRecreo": false,
    "esAlmuerzo": false,
    "nombre": "",
    "alarmaActiva": false
  }
]
```

**Nota sobre colores**: Los colores se almacenan como enteros que representan valores ARGB32. Un valor `null` significa sin color.

### Solución de Problemas

#### Error: "relation configuraciones_horario already exists"
Si la tabla ya existe, puedes:
1. Eliminarla primero: `DROP TABLE IF EXISTS configuraciones_horario CASCADE;`
2. O simplemente ignorar el error si la tabla ya está creada correctamente

#### Error: "permission denied"
Asegúrate de que estás conectado con un usuario que tenga permisos de administrador en la base de datos.

#### Los datos no se guardan
Verifica que:
1. El usuario esté autenticado (`auth.uid()` no sea null)
2. Las políticas RLS estén activas
3. El JSON sea válido

### Rollback

Si necesitas eliminar la tabla:

```sql
-- ADVERTENCIA: Esto eliminará todos los datos guardados
DROP TABLE IF EXISTS configuraciones_horario CASCADE;
```

## Respaldo de Datos

Es recomendable hacer un respaldo antes de ejecutar migraciones:

```bash
# Usando Supabase CLI
supabase db dump -f backup.sql

# O desde la interfaz de Supabase
# Dashboard > Database > Backups
```

---

## Configuración de la tabla `datos_centro_educativo`

La tabla `datos_centro_educativo` almacena la información del centro educativo del usuario, incluyendo:
- Nombre, dirección y contacto del centro
- Códigos de gestión SIGERD y cartografía
- Datos del director
- Datos del docente encargado de curso
- Regional y Distrito
- Sector (Público/Privado/Semioficial)
- Zona (Urbana/Rural/etc.)
- Jornada (Matutina/Vespertina/etc.)

### Cómo ejecutar la migración

Sigue los mismos pasos que para `configuraciones_horario`, pero ejecutando el archivo:
```
database/migrations/datos_centro_educativo.sql
```

### Verificar que la tabla se creó correctamente

```sql
SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'datos_centro_educativo';
```

### Estructura de datos

Los datos se almacenan directamente como columnas en la tabla:
- `nombre_centro` (text)
- `direccion` (text)
- `correo` (text)
- `telefono_centro` (text)
- `codigo_gestion` (text)
- `codigo_cartografia` (text)
- `director_nombre` (text)
- `director_correo` (text)
- `director_telefono` (text)
- `docente_nombre` (text)
- `docente_correo` (text)
- `docente_telefono` (text)
- `regional` (text)
- `distrito` (text)
- `sector` (text)
- `zona` (text)
- `jornada` (text)

---

---

## Configuración de la tabla `datos_generales_estudiantes`

La tabla `datos_generales_estudiantes` almacena los datos de hasta 40 estudiantes en formato tabla, incluyendo:
- Nombres completos (40 filas)
- Campos adicionales por estudiante:
  - Columna 0: Sexo (M/F)
  - Columna 1: Día de nacimiento
  - Columna 2: Mes de nacimiento
  - Columna 3: Año de nacimiento
  - Columna 4: Libro
  - Columna 5: Folio
  - Columna 6: Acta
  - Columna 7: Cédula
  - Columna 8: RNE
  - Columna 9: Dirección

### Cómo ejecutar la migración

```
database/migrations/datos_generales_estudiantes.sql
```

### Verificar que la tabla se creó correctamente

```sql
SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'datos_generales_estudiantes';
```

### Estructura de datos

Los datos se almacenan en formato JSONB:
```json
{
  "nombres": ["Juan Pérez", "María García", ..., ""],
  "campos_adicionales": [
    {
      "col_0": "M",
      "col_1": "15",
      "col_2": "05",
      "col_3": "2010",
      "col_4": "",
      "col_5": "",
      "col_6": "",
      "col_7": "",
      "col_8": "",
      "col_9": ""
    },
    // ... hasta 40 filas
  ]
}
```

**Nota**: Los datos se guardan por curso. Un usuario puede tener múltiples registros, uno por cada curso que gestione.

---

## Configuración de la tabla `condicion_inicial_estudiantes`

La tabla `condicion_inicial_estudiantes` almacena la condición inicial de hasta 40 estudiantes en formato tabla, incluyendo:
- Correo electrónico por estudiante
- Estado de condición inicial:
  - Promovido
  - Repitente
  - Reingreso
  - Aplazado

### Cómo ejecutar la migración

```
database/migrations/condicion_inicial_estudiantes.sql
```

### Verificar que la tabla se creó correctamente

```sql
SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'condicion_inicial_estudiantes';
```

### Estructura de datos

Los datos se almacenan en formato JSONB:
```json
{
  "condiciones": [
    {
      "correo": "estudiante1@example.com",
      "promovido": true,
      "repitente": false,
      "reingreso": false,
      "aplazado": false
    },
    {
      "correo": "estudiante2@example.com",
      "promovido": false,
      "repitente": true,
      "reingreso": false,
      "aplazado": false
    },
    // ... hasta 40 filas
  ]
}
```

**Nota**: Los estados son mutuamente excluyentes. Solo uno puede estar activo a la vez por estudiante.

**Nota**: Los datos se guardan por curso. Un usuario puede tener múltiples registros, uno por cada curso que gestione.

---

## Configuración de la tabla `datos_emergencias_estudiantes`

La tabla `datos_emergencias_estudiantes` almacena los datos de emergencias de hasta 40 estudiantes en formato tabla, incluyendo:
- Enfermedades o alergias
- Medicamentos que usa
- Nombre y apellido del contacto de emergencia
- Teléfono del contacto
- Parentesco de la persona con la que vive

### Cómo ejecutar la migración

```
database/migrations/datos_emergencias_estudiantes.sql
```

### Verificar que la tabla se creó correctamente

```sql
SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'datos_emergencias_estudiantes';
```

### Estructura de datos

Los datos se almacenan en formato JSONB:
```json
{
  "emergencias": [
    {
      "enfermedades": "Asma",
      "medicamentos": "Inhalador",
      "nombreApellido": "María García",
      "telefono": "809-555-1234",
      "parentesco": "Madre"
    },
    {
      "enfermedades": "",
      "medicamentos": "",
      "nombreApellido": "Pedro Sánchez",
      "telefono": "809-555-5678",
      "parentesco": "Padre"
    },
    // ... hasta 40 filas
  ]
}
```

**Nota**: Los datos se guardan por curso. Un usuario puede tener múltiples registros, uno por cada curso que gestione.

---

## Configuración de la tabla `parentesco_estudiantes`

La tabla `parentesco_estudiantes` almacena los datos de parentesco de hasta 40 estudiantes en formato tabla, incluyendo:
- Nombre y apellido del padre
- Teléfono del padre
- Nombre y apellido de la madre
- Teléfono de la madre
- Nombre y apellido del tutor
- Teléfono del tutor

### Cómo ejecutar la migración

```
database/migrations/parentesco_estudiantes.sql
```

### Verificar que la tabla se creó correctamente

```sql
SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'parentesco_estudiantes';
```

### Estructura de datos

Los datos se almacenan en formato JSONB:
```json
{
  "parentescos": [
    {
      "padreNombre": "Juan Pérez",
      "padreTelefono": "809-555-1234",
      "madreNombre": "María García",
      "madreTelefono": "809-555-5678",
      "tutorNombre": "Pedro Martínez",
      "tutorTelefono": "809-555-9012"
    },
    {
      "padreNombre": "Carlos López",
      "padreTelefono": "809-555-3456",
      "madreNombre": "Ana Rodríguez",
      "madreTelefono": "809-555-7890",
      "tutorNombre": "",
      "tutorTelefono": ""
    },
    // ... hasta 40 filas
  ]
}
```

**Nota**: Los datos se guardan por curso. Un usuario puede tener múltiples registros, uno por cada curso que gestione.

---

## Configuración de las tablas de Asistencia

### Tabla `asistencia_registros_meses`

Almacena la lista de 10 meses consecutivos creados para cada curso/sección.

#### Cómo ejecutar la migración

```
database/migrations/asistencia_registros_meses.sql
```

#### Estructura de datos

```json
{
  "registros": [
    {"mes": "Agosto", "materia": "4to", "seccion": "A"},
    {"mes": "Septiembre", "materia": "4to", "seccion": "A"},
    {"mes": "Octubre", "materia": "4to", "seccion": "A"},
    // ... hasta 10 meses
  ]
}
```

### Tabla `asistencia_datos_mes`

Almacena los datos completos de asistencia de un mes específico: matriz de 40 estudiantes x 22 columnas (días 1-20, total T, porcentaje %), feriados y días del mes.

#### Cómo ejecutar la migración

```
database/migrations/asistencia_datos_mes.sql
```

#### Estructura de datos

```json
{
  "asistencia": [
    ["", "", "", ...],  // 22 columnas por estudiante
    ["", "", "", ...],
    // ... 40 filas (estudiantes)
  ],
  "feriados": {
    "5": "Día de la Constitución",
    "15": "Día de las Madres"
  },
  "diasMes": ["1", "2", "3", ..., "21"],
  "ultimaActualizacion": "2025-01-08T12:00:00Z"
}
```

**Nota**: Los datos de asistencia se guardan automáticamente con cada cambio.

---

## Configuración de las tablas de Calificaciones

### Tabla `calificaciones_notas_grupos`

Almacena las notas de los 4 grupos de calificaciones para cada curso/sección. Cada grupo contiene una matriz de 40 estudiantes x 8 columnas.

#### Cómo ejecutar la migración

```
database/migrations/calificaciones_notas_grupos.sql
```

#### Estructura de datos

```json
{
  "grupo1": [
    ["", "", "", "", "", "", "", ""],  // Estudiante 1: 8 columnas
    ["", "", "", "", "", "", "", ""],  // Estudiante 2: 8 columnas
    // ... hasta 40 estudiantes
  ],
  "grupo2": [
    // ... mismo formato que grupo1
  ],
  "grupo3": [
    // ... mismo formato que grupo1
  ],
  "grupo4": [
    // ... mismo formato que grupo1
  ],
  "ultimaActualizacion": "2025-01-08T12:00:00Z"
}
```

**Nota**: Cada grupo representa un período de calificaciones con 8 columnas de evaluación.

### Tabla `promocion_grado_datos`

Almacena los datos completos de promoción del grado, incluyendo la matriz de datos de estudiantes y metadatos del curso.

#### Cómo ejecutar la migración

```
database/migrations/promocion_grado_datos.sql
```

#### Estructura de datos

```json
{
  "datosPromocion": [
    ["", "", "", "", ...],  // Estudiante 1: todas las columnas
    ["", "", "", "", ...],  // Estudiante 2: todas las columnas
    // ... hasta 40 estudiantes
  ],
  "asignatura": "Matemática",
  "grado": "4to",
  "docente": "Nombre del Docente",
  "ultimaActualizacion": "2025-01-08T12:00:00Z"
}
```

**Nota**: Los datos de calificaciones se guardan automáticamente y se vinculan por curso y sección.

---

## Configuración de la tabla de Evaluaciones por Días

### Tabla `evaluaciones_dias`

Almacena las evaluaciones de 10 días para cada curso. Cada estudiante tiene 10 campos correspondientes a los días de evaluación.

#### Cómo ejecutar la migración

```
database/migrations/evaluaciones_dias.sql
```

#### Estructura de datos

```json
{
  "nombreDocente": "Nombre del Docente",
  "grado": "5to",
  "estudiantes": [
    {"1": "", "2": "", "3": "", "4": "", "5": "", "6": "", "7": "", "8": "", "9": "", "10": ""},  // Estudiante 1
    {"1": "P", "2": "A", "3": "T", "4": "E", "5": "R", "6": "", "7": "", "8": "", "9": "", "10": ""},  // Estudiante 2
    // ... hasta 40 estudiantes
  ],
  "ultimaActualizacion": "2025-01-08T12:00:00Z"
}
```

**Nota**: Las evaluaciones pueden usar códigos como P (Presente), A (Ausencia), T (Tardanza), E (Excusa), R (Retiro voluntario), o valores numéricos según la necesidad.

**Nota**: Los datos se guardan automáticamente con cada cambio y se vinculan por curso_id.

---

## Ejecutar Todas las Migraciones

Para ejecutar todas las migraciones de una vez:

1. Ve a Supabase Dashboard → SQL Editor
2. Ejecuta en orden:
   - `configuraciones_horario.sql`
   - `datos_centro_educativo.sql`
   - `datos_generales_estudiantes.sql`
   - `condicion_inicial_estudiantes.sql`
   - `datos_emergencias_estudiantes.sql`
   - `parentesco_estudiantes.sql`
   - `asistencia_registros_meses.sql`
   - `asistencia_datos_mes.sql`
   - `calificaciones_notas_grupos.sql`
   - `promocion_grado_datos.sql`
   - `evaluaciones_dias.sql`

O copia y pega los once archivos en una sola consulta.

## Próximas Migraciones

Cuando agregues nuevas migraciones, nómbralas con un prefijo numérico o de fecha:
- `001_configuraciones_horario.sql`
- `002_datos_centro_educativo.sql`
- `003_agregar_campo_x.sql`
- `20250108_nueva_tabla.sql`
