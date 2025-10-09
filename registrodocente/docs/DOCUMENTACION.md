# 📚 Documentación - Registro Docente

## 📋 Índice
1. [Descripción General](#descripción-general)
2. [Autenticación](#autenticación)
3. [Pantalla Principal (Home)](#pantalla-principal-home)
4. [Gestión de Cursos](#gestión-de-cursos)
5. [Gestión de Estudiantes](#gestión-de-estudiantes)
6. [Sistema de Asistencias](#sistema-de-asistencias)
7. [Sistema de Calificaciones](#sistema-de-calificaciones)
8. [Promoción de Grado](#promoción-de-grado)
9. [Horario de Clases](#horario-de-clases)
10. [Calendario Escolar](#calendario-escolar)
11. [Perfil de Usuario](#perfil-de-usuario)
12. [Almacenamiento y Persistencia](#almacenamiento-y-persistencia)
13. [Tecnologías Utilizadas](#tecnologías-utilizadas)

---

## 🎯 Descripción General

**Registro Docente** es una aplicación web y móvil diseñada para facilitar la gestión académica de docentes en centros educativos de República Dominicana. La aplicación permite gestionar cursos, estudiantes, asistencias, calificaciones y más, todo desde una interfaz intuitiva y moderna.

**URL de producción:** https://registrodocente.online

**Características principales:**
- ✅ Gestión completa de cursos y secciones
- ✅ Registro y seguimiento de estudiantes
- ✅ Sistema de asistencias diarias
- ✅ Sistema de calificaciones por competencias
- ✅ Promoción automática de estudiantes
- ✅ Horario de clases personalizable
- ✅ Calendario escolar
- ✅ Guardado automático de todos los cambios
- ✅ Funciona offline (datos guardados localmente)
- ✅ Multiplataforma (Web, Android, iOS, Desktop)

---

## 🔐 Autenticación

### Pantalla de Inicio de Sesión (Sign In)

**Ubicación:** `/sign-in`

**Funcionalidades:**
- Login con correo electrónico y contraseña
- Validación de credenciales con Supabase
- Guardado automático de sesión
- Recuperación de datos del usuario
- Redirección automática al Home tras login exitoso

**Campos:**
- **Correo electrónico:** Validación de formato email
- **Contraseña:** Campo oculto con opción de mostrar/ocultar

**Validaciones:**
- Correo electrónico válido (debe contener @)
- Contraseña no vacía
- Verificación de credenciales en servidor

**Flujo:**
1. Usuario ingresa email y contraseña
2. Sistema valida credenciales en Supabase
3. Si es exitoso, guarda datos en SharedPreferences
4. Redirige a la pantalla Home

---

### Pantalla de Registro (Sign Up)

**Ubicación:** `/sign-up`

**Funcionalidades:**
- Creación de nueva cuenta de usuario
- Validación de datos en tiempo real
- Confirmación de contraseña
- Envío de email de verificación
- Guardado de datos iniciales del usuario

**Campos:**
- **Nombre completo:** Mínimo 3 caracteres
- **Correo electrónico:** Validación de formato
- **Contraseña:** Mínimo 6 caracteres
- **Confirmar contraseña:** Debe coincidir con la contraseña

**Validaciones:**
- Nombre: mínimo 3 caracteres
- Email: formato válido con @
- Contraseña: mínimo 6 caracteres
- Confirmación: debe coincidir exactamente
- Email único (no registrado previamente)

**Flujo:**
1. Usuario completa el formulario
2. Sistema valida todos los campos
3. Crea cuenta en Supabase con metadata del usuario
4. Envía email de verificación
5. Muestra mensaje de confirmación
6. Redirige a pantalla de login

---

## 🏠 Pantalla Principal (Home)

**Ubicación:** `/home`

### Funcionalidades Principales

#### 1. **Perfil del Usuario**
- Avatar personalizado basado en género
- Nombre del docente
- Centro educativo
- Regional y Distrito
- Acceso rápido al perfil (tap en avatar)

#### 2. **Accesos Rápidos Inteligentes**
- Muestra las 5 actividades más utilizadas
- Se actualiza automáticamente según uso
- Ordenamiento por frecuencia
- Acceso con un solo tap

**Actividades disponibles:**
- Asistencia
- Calificaciones
- Promoción
- Horario
- Calendario
- Cursos
- Perfil

#### 3. **Sistema de Advertencias**
- Notificaciones importantes en tiempo real
- Badge con cantidad de advertencias
- Categorías:
  - ⚠️ Asistencias pendientes
  - ⚠️ Calificaciones incompletas
  - ⚠️ Configuraciones faltantes

**Características:**
- Icono de advertencia con contador
- Modal con lista detallada
- Navegación directa a la sección correspondiente
- Códigos de color por tipo de advertencia

#### 4. **Menú Principal**
Acceso a las tres funcionalidades principales:
- 📚 **Cursos:** Gestión de cursos y secciones
- ⏰ **Horario de clase:** Configuración de horarios
- 📅 **Calendario escolar:** Eventos y fechas importantes

#### 5. **Configuración**
- Modo oscuro (en desarrollo)
- Cerrar sesión con confirmación
- Ajustes de la aplicación

---

## 📚 Gestión de Cursos

**Ubicación:** `/cursos`

### Funcionalidades Principales

#### 1. **Visualización de Cursos**

**Formato de cursos:** `[Grado/Nivel] [Sección] - [Asignatura]`

Ejemplos:
- Tercero A - Lengua Española
- Quinto B - Matemáticas
- Primero C - Ciencias Sociales

**Información mostrada:**
- Nombre completo del curso
- Número de secciones
- Badge "Activo" para el curso seleccionado
- Badge "Oculto" para cursos ocultos
- Indicador visual con colores únicos

#### 2. **Crear Nuevo Curso**

**Botón:** `+` en AppBar

**Campos requeridos:**
- **Nombre del Curso:** Ej: "Tercero A"
- **Asignatura:** Ej: "Lengua Española"

**Proceso:**
1. Tap en botón `+`
2. Completar formulario
3. Sistema crea curso con formato: `[Nombre] - [Asignatura]`
4. Se crea automáticamente con Sección "A"
5. El nuevo curso aparece al inicio de la lista
6. Guardado automático

#### 3. **Editar Curso**

**Acceso:** Tap en opciones (⋮) → Editar

**Funcionalidades:**
- Cambiar nombre del curso
- Actualización en tiempo real
- Mantiene secciones asociadas
- Guardado automático

#### 4. **Gestión de Secciones**

**Acceso:** Tap en opciones (⋮) del curso

**Funcionalidades:**

**Agregar Sección:**
- Genera automáticamente la siguiente letra (A→B→C...)
- Guardado automático
- Actualiza contador de secciones

**Eliminar Sección:**
- Long press en la sección
- Requiere confirmación
- Solo si hay más de 1 sección
- Se mueve a la papelera
- Posibilidad de restaurar

**Acceder a Sección:**
- Tap en cualquier sección
- Abre vista detallada del curso/sección
- Muestra estudiantes de esa sección

#### 5. **Curso Activo**

**Funcionalidad:** Permite seleccionar el curso en el que estás trabajando actualmente

**Cómo usar:**
1. Tap simple en cualquier curso
2. Aparece badge "Activo"
3. Notificación de confirmación
4. Todas las funciones (asistencia, calificaciones) usan este curso
5. Persiste entre sesiones

**Indicadores visuales:**
- Border azul alrededor del curso activo
- Badge "Activo" con checkmark
- Mensaje de confirmación con nombre del curso

#### 6. **Ocultar/Mostrar Cursos**

**Funcionalidad:** Oculta cursos que no estás usando actualmente

**Proceso:**
1. Tap en opciones (⋮) del curso
2. Seleccionar "Ocultar Curso"
3. Curso desaparece de la vista principal
4. Badge "Oculto" cuando se muestran cursos ocultos

**Ver cursos ocultos:**
- Toggle en AppBar (ícono ojo)
- Muestra/oculta cursos marcados como ocultos
- Se pueden restaurar desde aquí

#### 7. **Reordenar Cursos**

**Funcionalidad:** Organiza el orden de visualización de los cursos

**Proceso:**
1. Tap en ícono de reordenar (swap_vert) en AppBar
2. Modo de reordenamiento activado
3. Drag & drop para cambiar orden
4. Tap en "Listo" para guardar
5. Guardado automático del nuevo orden

**Características:**
- Arrastrar con ícono de manijas (☰)
- Vista previa en tiempo real
- Persiste el orden guardado
- Nuevos cursos aparecen al inicio por defecto

#### 8. **Papelera de Cursos**

**Acceso:** Ícono de papelera (🗑️) en AppBar

**Funcionalidades:**

**Eliminar Curso:**
1. Long press en curso
2. Confirmación de eliminación
3. Se mueve a papelera con todas sus secciones

**Restaurar Curso:**
- Desde la papelera
- Restaura curso completo con secciones
- Vuelve a la lista principal

**Eliminar Permanentemente:**
- Elimina definitivamente el curso
- No se puede deshacer
- Requiere doble confirmación

**Papelera de Secciones:**
- Listado separado de secciones eliminadas
- Restauración individual
- Eliminación permanente individual

#### 9. **Información del Docente**

**Visualización en pantalla:**
- Avatar con género
- Nombre: Francisco Luis Yean
- Centro: Centro Educativo Eugenio M. de Hostos
- Regional: 17
- Distrito: 04

---

## 👥 Gestión de Estudiantes

### Pantalla de Detalle de Curso

**Ubicación:** `/curso_detalle`

**Parámetros:**
- `curso`: Nombre del curso
- `seccion`: Letra de la sección

#### Funcionalidades Principales

**1. Agregar Estudiante**
- Botón flotante (+) para agregar
- Formulario de datos completo
- Múltiples pantallas de información

**2. Editar Estudiante**
- Tap en estudiante existente
- Modificación de todos los datos
- Guardado automático

**3. Ver Estudiante**
- Información completa del estudiante
- Navegación entre secciones
- Datos organizados por categorías

---

### Información General del Estudiante

**Ubicación:** `/general_info`

#### Datos Básicos
- **Nombre completo**
- **Cédula/Identificación**
- **Fecha de nacimiento**
- **Edad (calculada automáticamente)**
- **Género**
- **Nacionalidad**

#### Datos de Contacto
- **Dirección completa**
- **Teléfono**
- **Correo electrónico**

---

### Centro Educativo

**Ubicación:** `/centro_educativo`

#### Información del Centro
- **Nombre del centro educativo**
- **Código del centro**
- **Regional**
- **Distrito**
- **Dirección del centro**
- **Teléfono del centro**

#### Datos Académicos
- **Grado actual**
- **Sección**
- **Año escolar**
- **Tanda:** Matutina/Vespertina/Nocturna

---

### Datos de Emergencia

**Ubicación:** `/emergency_data`

#### Contactos de Emergencia
**Contacto Principal:**
- Nombre completo
- Relación con el estudiante
- Teléfono primario
- Teléfono secundario

**Contacto Secundario:**
- Nombre completo
- Relación con el estudiante
- Teléfono primario
- Teléfono secundario

#### Información Médica
- **Tipo de sangre**
- **Alergias conocidas**
- **Condiciones médicas**
- **Medicamentos actuales**
- **Seguro médico**
- **Número de afiliación**

---

### Parentesco/Tutores

**Ubicación:** `/parentesco`

#### Datos del Padre
- Nombre completo
- Cédula
- Ocupación
- Teléfono
- Correo electrónico
- Dirección

#### Datos de la Madre
- Nombre completo
- Cédula
- Ocupación
- Teléfono
- Correo electrónico
- Dirección

#### Tutor Legal (si aplica)
- Nombre completo
- Cédula
- Relación con el estudiante
- Teléfono
- Correo electrónico
- Dirección
- Documento legal de tutoría

---

### Condición Inicial

**Ubicación:** `/condicion_inicial`

#### Evaluación de Ingreso
- **Fecha de ingreso**
- **Nivel de español**
- **Nivel de matemáticas**
- **Nivel de lectura**
- **Nivel de escritura**

#### Antecedentes Académicos
- **Centro anterior**
- **Último grado cursado**
- **Promedio general**
- **Repitencia:** Sí/No
- **Grado repetido**

#### Necesidades Especiales
- **Requiere apoyo educativo:** Sí/No
- **Tipo de apoyo**
- **Observaciones**
- **Adaptaciones curriculares**

---

## ✅ Sistema de Asistencias

### Menú de Asistencias

**Ubicación:** `/asistencias_menu`

**Opciones disponibles:**
1. **Registro de Asistencia Diaria**
2. **Asistencias y Evaluaciones (Tabla)**
3. **Reportes de Asistencia**
4. **Historial de Asistencias**

---

### Asistencia Diaria

**Ubicación:** `/asistencia`

#### Funcionalidades

**1. Selección de Fecha**
- Calendario integrado
- Fecha actual por defecto
- Navegación entre fechas
- Indicador visual de fechas con asistencia

**2. Registro de Asistencia**

**Estados disponibles:**
- ✅ **P - Presente** (Verde)
- ❌ **A - Ausencia** (Rojo)
- ⏰ **T - Tardanza** (Naranja)
- 📋 **E - Excusa** (Amarillo)
- 🚪 **R - Retiro voluntario** (Morado)

**Proceso:**
1. Seleccionar fecha
2. Lista completa de estudiantes del curso activo
3. Tap en estudiante para marcar asistencia
4. Selección rápida con códigos
5. Guardado automático
6. Indicador visual por color

**3. Estadísticas en Tiempo Real**
- Total de presentes
- Total de ausencias
- Total de tardanzas
- Porcentaje de asistencia
- Gráfico visual

**4. Filtros y Búsqueda**
- Buscar estudiante por nombre
- Filtrar por estado de asistencia
- Ver solo presentes/ausentes

---

### Tabla de Asistencias y Evaluaciones

**Ubicación:** `/asistencia_evaluaciones`

#### Características

**1. Datos del Docente**
- Nombre del docente (editable)
- Grado (editable)
- Guardado automático

**2. Tabla de Asistencias**
- **Columnas:** 10 días
- **Filas:** 40 estudiantes
- **Celdas editables** para cada día

**3. Códigos de Asistencia**
Mismo sistema de códigos que asistencia diaria:
- P, A, T, E, R

**4. Funcionalidades**
- Clic en celda para editar
- Selección desde menú de opciones
- Colores automáticos por código
- Vista de tabla completa
- Scroll horizontal para más días
- Guardado automático

**5. Acciones**
- **Verificar:** Validación de asistencias
- **Imprimir:** Exportar tabla a PDF
- **Guardar:** Confirmar cambios (también automático)

**Guardado Automático:**
- Al cambiar nombre del docente
- Al cambiar grado
- Al marcar cada asistencia
- Datos separados por curso

---

## 📊 Sistema de Calificaciones

**Ubicación:** `/calificaciones`

### Funcionalidades Principales

#### 1. **Sistema de Competencias**

**Competencias Fundamentales:**
1. **Comunicativa**
2. **Pensamiento Lógico**
3. **Ética y Ciudadana**
4. **Resolución de Problemas**
5. **Científica y Tecnológica**
6. **Ambiental y de Salud**
7. **Desarrollo Personal y Espiritual**

#### 2. **Períodos de Evaluación**
- Primer Período
- Segundo Período
- Tercer Período
- Cuarto Período

#### 3. **Registro de Calificaciones**

**Proceso:**
1. Seleccionar estudiante
2. Seleccionar competencia
3. Seleccionar período
4. Ingresar calificación
5. Guardado automático

**Escalas de Calificación:**
- **Numérica:** 0-100
- **Literal:** A, B, C, D, F
- **Descriptiva:** Excelente, Muy Bien, Bien, Regular, Insuficiente

#### 4. **Visualización**
- Lista de estudiantes
- Tabla de calificaciones
- Promedio por estudiante
- Promedio por competencia
- Promedio general del curso

#### 5. **Reportes**
- Reporte individual por estudiante
- Reporte grupal del curso
- Reporte por competencia
- Exportación a PDF
- Exportación a Excel

#### 6. **Estadísticas**
- Promedio del curso
- Estudiantes destacados
- Estudiantes con bajo rendimiento
- Gráficos de rendimiento
- Comparativas por período

---

## 🎓 Promoción de Grado

**Ubicación:** `/promocion_grado`

### Funcionalidades

#### 1. **Evaluación Automática**

**Criterios de Promoción:**
- Promedio general ≥ 70
- Asistencia ≥ 80%
- Todas las competencias aprobadas
- Sin materias pendientes

#### 2. **Estados de Promoción**
- ✅ **Promovido:** Cumple todos los criterios
- ⚠️ **Promovido Condicionalmente:** Cumple criterios mínimos
- ❌ **Reprobado:** No cumple criterios
- 📋 **Pendiente de Evaluación:** Sin calificaciones completas

#### 3. **Proceso de Promoción**

**Pasos:**
1. Sistema evalúa automáticamente todos los estudiantes
2. Muestra lista con estado de cada estudiante
3. Docente puede revisar y ajustar
4. Confirmar promociones
5. Generar actas oficiales

#### 4. **Visualización**
- Lista de estudiantes por estado
- Filtros por estado de promoción
- Detalle de cada estudiante
- Indicadores visuales claros

#### 5. **Reportes y Actas**
- Acta de promoción oficial
- Listado de promovidos
- Listado de reprobados
- Estadísticas generales
- Exportación a PDF

#### 6. **Acciones Disponibles**
- Promover manualmente
- Reprobar con justificación
- Promoción condicional
- Revisión de casos especiales
- Guardar decisiones

---

## ⏰ Horario de Clases

**Ubicación:** `/horario-clase`

### Funcionalidades

#### 1. **Configuración de Horario**

**Días de la Semana:**
- Lunes
- Martes
- Miércoles
- Jueves
- Viernes

**Bloques de Tiempo:**
- Configurable por el docente
- Hora de inicio
- Hora de fin
- Duración de período

#### 2. **Asignación de Clases**

**Datos por bloque:**
- Asignatura/Materia
- Curso/Sección
- Aula/Salón
- Notas adicionales

**Proceso:**
1. Seleccionar día
2. Seleccionar bloque horario
3. Asignar asignatura
4. Seleccionar curso/sección
5. Indicar aula
6. Guardado automático

#### 3. **Visualización**
- Vista semanal completa
- Vista por día
- Códigos de color por asignatura
- Bloques libres claramente marcados

#### 4. **Funcionalidades Adicionales**
- Duplicar horario a otros días
- Copiar semana completa
- Plantillas de horario
- Recordatorios de clases
- Exportar horario a imagen/PDF

---

## 📅 Calendario Escolar

**Ubicación:** `/calendario-escolar`

### Funcionalidades

#### 1. **Vista de Calendario**
- Vista mensual
- Vista semanal
- Vista de agenda
- Navegación entre meses

#### 2. **Tipos de Eventos**

**Categorías:**
- 📚 **Eventos Académicos**
  - Inicio de clases
  - Fin de período
  - Exámenes
  - Entrega de notas

- 🎉 **Eventos Especiales**
  - Actos cívicos
  - Celebraciones
  - Día del maestro
  - Graduaciones

- ⚠️ **Fechas Importantes**
  - Días feriados
  - Asuetos
  - Suspensiones de docencia
  - Reuniones de padres

- 📋 **Administrativos**
  - Juntas de docentes
  - Capacitaciones
  - Evaluaciones institucionales

#### 3. **Gestión de Eventos**

**Crear Evento:**
- Título del evento
- Descripción
- Fecha y hora
- Categoría
- Recordatorio

**Editar Evento:**
- Modificar cualquier campo
- Guardado automático

**Eliminar Evento:**
- Confirmación requerida
- Opción de eliminar serie completa

#### 4. **Notificaciones**
- Recordatorios configurables
- 1 día antes
- 1 hora antes
- Al momento del evento

#### 5. **Filtros**
- Por categoría
- Por mes
- Por tipo de evento
- Eventos propios vs. institucionales

---

## 👤 Perfil de Usuario

**Ubicación:** `/perfil`

### Funcionalidades

#### 1. **Información Personal**

**Datos del Docente:**
- Foto de perfil
- Nombre completo
- Cédula
- Fecha de nacimiento
- Género
- Teléfono
- Correo electrónico

#### 2. **Información Profesional**

**Datos Laborales:**
- Centro educativo
- Regional
- Distrito
- Cargo/Posición
- Años de servicio
- Especialidad/Área
- Título académico

#### 3. **Cambiar Foto de Perfil**

**Opciones:**
- Tomar foto con cámara
- Seleccionar de galería
- Usar avatar predeterminado
- Eliminar foto actual

#### 4. **Editar Información**
- Todos los campos editables
- Validación de datos
- Guardado automático
- Confirmación de cambios

#### 5. **Configuración de Cuenta**
- Cambiar contraseña
- Cambiar email
- Configuración de privacidad
- Preferencias de notificaciones

#### 6. **Estadísticas del Docente**
- Total de cursos
- Total de estudiantes
- Asistencia promedio
- Rendimiento promedio
- Años de servicio

---

## 💾 Almacenamiento y Persistencia

### Sistema de Guardado Automático

**Todas las funcionalidades guardan automáticamente los cambios.**

#### Tecnología Utilizada
- **SharedPreferences:** Almacenamiento local
- **JSON:** Formato de datos
- **Supabase:** Autenticación de usuarios

#### Datos Guardados Localmente

**1. Cursos:**
- Lista de cursos
- Secciones de cada curso
- Cursos ocultos
- Orden de cursos
- Curso activo
- Papelera de cursos
- Papelera de secciones

**2. Estudiantes:**
- Datos personales completos
- Datos académicos
- Datos de emergencia
- Información de tutores
- Condición inicial
- Por curso/sección

**3. Asistencias:**
- Registro diario por fecha
- Tabla de asistencias mensual
- Por curso activo
- Estadísticas

**4. Calificaciones:**
- Por estudiante
- Por competencia
- Por período
- Promedios calculados

**5. Configuración:**
- Preferencias de usuario
- Horarios configurados
- Eventos del calendario
- Actividades frecuentes

#### Características del Guardado

**Automático:**
- Sin necesidad de botón "Guardar"
- Guardado en tiempo real
- Al cambiar cualquier dato
- Al cerrar la aplicación

**Persistente:**
- Datos se mantienen al cerrar la app
- Sobrevive a reinicios
- Sincronizable entre dispositivos
- No se pierde al actualizar

**Seguro:**
- Datos cifrados
- Solo accesibles por el usuario
- Respaldo automático
- Recuperación de datos

#### Sincronización (Futuro)
- Sincronización con Supabase
- Backup en la nube
- Acceso desde múltiples dispositivos
- Versionado de datos

---

## 🛠 Tecnologías Utilizadas

### Frontend
- **Flutter 3.x:** Framework multiplataforma
- **Dart:** Lenguaje de programación
- **Material Design 3:** Sistema de diseño

### Backend y Servicios
- **Supabase:**
  - Autenticación de usuarios
  - Base de datos PostgreSQL
  - Almacenamiento de archivos
  - Funciones serverless

### Almacenamiento Local
- **SharedPreferences:** Datos clave-valor
- **JSON:** Serialización de datos

### Hosting y Deploy
- **Netlify:** Hosting de aplicación web
- **DNS:** GoDaddy (registrodocente.online)
- **SSL:** Certificado automático

### Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  shared_preferences: ^2.2.2
  pdf: ^3.10.7
  csv: ^6.0.0
```

### Arquitectura
- **Patrón:** Clean Architecture
- **Estado:** Provider/Riverpod
- **Routing:** Named Routes
- **Inyección de dependencias:** GetIt/Injector

---

## 📱 Plataformas Soportadas

- ✅ **Web** (Chrome, Firefox, Safari, Edge)
- ✅ **Android** (5.0+)
- ✅ **iOS** (11.0+)
- ✅ **Windows** (10+)
- ✅ **macOS** (10.14+)
- ✅ **Linux**

---

## 🚀 Funcionalidades Futuras

### En Desarrollo
- [ ] Modo oscuro completo
- [ ] Exportación masiva de reportes
- [ ] Sincronización en la nube
- [ ] Chat entre docentes
- [ ] Notificaciones push

### Planificadas
- [ ] App móvil nativa
- [ ] Integración con MINERD
- [ ] Firma digital de documentos
- [ ] Módulo de tareas y asignaciones
- [ ] Portal para padres
- [ ] Dashboard administrativo
- [ ] Analytics y reportes avanzados

---

## 📞 Soporte y Contacto

**URL:** https://registrodocente.online

**Desarrollado por:** Francisco Luis Yean

**Versión:** 1.0.0

**Última actualización:** Octubre 2025

---

## 📄 Licencia

Copyright © 2025 - Todos los derechos reservados.

---

## 🔄 Historial de Versiones

### Versión 1.0.0 (Actual)
- ✅ Sistema de autenticación completo
- ✅ Gestión de cursos y secciones
- ✅ Gestión de estudiantes
- ✅ Sistema de asistencias
- ✅ Sistema de calificaciones
- ✅ Promoción de grado
- ✅ Horario de clases
- ✅ Calendario escolar
- ✅ Perfil de usuario
- ✅ Guardado automático
- ✅ Responsive design
- ✅ Multiplataforma

---

**¡Gracias por usar Registro Docente! 📚✨**
