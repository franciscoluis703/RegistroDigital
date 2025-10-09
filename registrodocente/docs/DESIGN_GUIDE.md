# 🎨 Guía de Diseño - Registro Docente

## Paleta de Colores Educativa

### Colores Primarios
- **Azul Educativo** (`#2C3E95`) - Color principal, profesional y confiable
  - Uso: AppBar, botones principales, elementos destacados
  - Light: `#4F5FC7` | Dark: `#1E2870` | Surface: `#EEF2FF`

### Colores Secundarios
- **Verde Éxito** (`#10B981`) - Progreso y confirmación
  - Uso: Estados activos, confirmaciones, asistencias
  - Light: `#34D399` | Dark: `#059669` | Surface: `#D1FAE5`

### Colores Terciarios
- **Morado Académico** (`#8B5CF6`) - Creatividad y aprendizaje
  - Uso: Promoción de grado, elementos creativos
  - Light: `#A78BFA` | Dark: `#7C3AED` | Surface: `#EDE9FE`

### Colores de Acento
- **Naranja Energía** (`#F59E0B`) - Atención y dinamismo
  - Uso: Calificaciones, alertas importantes
  - Light: `#FBBF24` | Dark: `#D97706` | Surface: `#FEF3C7`

### Colores Temáticos por Sección
- 📋 **Datos Generales**: Azul Info (`#3B82F6`)
- ✅ **Asistencias**: Verde (`#10B981`)
- 📊 **Calificaciones**: Naranja (`#F59E0B`)
- 📈 **Promoción**: Morado (`#8B5CF6`)
- 📅 **Calendario**: Rosa (`#EC4899`)
- 🕐 **Horario**: Cian (`#06B6D4`)

### Colores de Estado
- ✅ **Éxito**: Verde (`#10B981`)
- ⚠️ **Advertencia**: Naranja (`#F59E0B`)
- ❌ **Error**: Rojo (`#EF4444`)
- ℹ️ **Info**: Azul (`#3B82F6`)

### Escala de Grises
- **Texto Principal**: `#1E293B`
- **Texto Secundario**: `#475569`
- **Texto Terciario**: `#64748B`
- **Texto Deshabilitado**: `#94A3B8`
- **Divisores**: `#E2E8F0`
- **Fondo**: `#F8FAFC`
- **Superficie**: `#FFFFFF`

## Tipografía

**Fuente**: Inter (Google Fonts)

### Jerarquía
- **Headlines Large**: 32px, Bold - Títulos principales
- **Headlines Medium**: 28px, Bold - Subtítulos importantes
- **Headlines Small**: 24px, Bold - Secciones
- **Title Large**: 20px, SemiBold - Títulos de cards
- **Title Medium**: 16px, SemiBold - Subtítulos
- **Body Large**: 16px, Normal - Texto principal
- **Body Medium**: 14px, Normal - Texto secundario
- **Body Small**: 12px, Normal - Texto pequeño
- **Label**: 11-14px, Medium - Etiquetas y badges

## Componentes Educativos

### EducationalCard
Card reutilizable con diseño consistente:
```dart
EducationalCard(
  icon: Icons.school,
  title: 'Título',
  subtitle: 'Descripción',
  color: AppColors.primary,
  onTap: () {},
)
```

### EducationalBadge
Badges para estados y etiquetas:
```dart
EducationalBadge(
  label: 'Activo',
  icon: Icons.check_circle,
  color: AppColors.secondary,
)
```

### SectionHeader
Encabezados de sección consistentes:
```dart
SectionHeader(
  title: 'Mis Cursos',
  subtitle: '5 cursos activos',
  icon: Icons.school,
  color: AppColors.primary,
)
```

### EmptyState
Estado vacío con diseño educativo:
```dart
EmptyState(
  icon: Icons.school_outlined,
  title: 'No hay cursos',
  message: 'Crea tu primer curso',
  actionLabel: 'Crear Curso',
  onActionPressed: () {},
)
```

## Espaciado

### Sistema de 8pt
- **Pequeño**: 8px
- **Mediano**: 16px
- **Grande**: 24px
- **Extra Grande**: 32px

### Márgenes y Padding
- **Cards**: 16px padding, 16px margin horizontal
- **Listas**: 8px entre items
- **Secciones**: 24px separación
- **Pantallas**: 16px padding general

## Bordes y Sombras

### Border Radius
- **Pequeño**: 8px - Chips, badges
- **Mediano**: 12px - Botones, inputs
- **Grande**: 16px - Cards principales
- **Extra Grande**: 20px - Modals, bottom sheets

### Elevaciones
- **Card Normal**: 2-4px blur, offset (0,2)
- **Card Activo**: 8px blur con color del estado
- **Modal/Dialog**: 8px
- **FloatingActionButton**: 4px

## Iconografía

### Tamaños
- **Pequeño**: 16px - Trailing icons
- **Normal**: 24px - Icons generales
- **Grande**: 28px - Icons en cards
- **Hero**: 64px - Empty states

### Íconos por Sección
- 📋 Datos Generales: `Icons.description`
- ✅ Asistencias: `Icons.checklist`
- 📊 Calificaciones: `Icons.grade`
- 📈 Promoción: `Icons.trending_up`
- 📅 Calendario: `Icons.calendar_month`
- 🕐 Horario: `Icons.schedule`
- 👤 Perfil: `Icons.person`
- ⚙️ Configuración: `Icons.settings`

## Estados Interactivos

### Botones
- **Normal**: Color sólido con elevation 2
- **Hover**: Ligero cambio de opacidad (web)
- **Pressed**: Elevation reducida
- **Disabled**: Opacidad 0.38, sin shadow

### Cards
- **Normal**: Fondo blanco, shadow suave
- **Activo**: Borde verde 2px, shadow verde
- **Oculto**: Fondo gris claro, shadow reducida
- **Hover**: Shadow aumentada (web)

## Animaciones

### Duración
- **Rápida**: 150ms - Hover, ripples
- **Normal**: 300ms - Transiciones generales
- **Lenta**: 500ms - Cambios de página

### Curvas
- **Standard**: easeInOut - General
- **Decelerate**: easeOut - Entrada
- **Accelerate**: easeIn - Salida

## Accesibilidad

### Contraste
- Texto sobre fondo claro: Mínimo 4.5:1
- Texto sobre color: Siempre usar blanco/negro para máximo contraste
- Estados deshabilitados: Claramente diferenciados

### Tamaños Táctiles
- Mínimo: 48x48px para todos los botones
- Espaciado entre elementos interactivos: Mínimo 8px

### Retroalimentación
- Ripple effect en todos los elementos interactivos
- SnackBars para confirmaciones
- Dialogs para acciones destructivas
- Loading states para operaciones async

## Mejores Prácticas

1. **Siempre usa AppColors** en lugar de hardcodear colores
2. **Usa widgets educativos** (EducationalCard, etc.) para consistencia
3. **Mantén jerarquía visual** con tamaños de texto apropiados
4. **Sigue el espaciado de 8pt** para alineación perfecta
5. **Usa colores temáticos** para cada sección del app
6. **Incluye estados vacíos** con EmptyState
7. **Añade feedback visual** a todas las interacciones
8. **Mantén accesibilidad** en contraste y tamaños táctiles

## Ejemplo de Pantalla Completa

```dart
Scaffold(
  backgroundColor: AppColors.background,
  appBar: AppBar(
    title: Text('Título'),
  ),
  body: SafeArea(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SectionHeader(
            title: 'Sección',
            icon: Icons.school,
          ),
          SizedBox(height: 16),
          EducationalCard(
            icon: Icons.book,
            title: 'Item',
            subtitle: 'Descripción',
            color: AppColors.primary,
            onTap: () {},
          ),
        ],
      ),
    ),
  ),
)
```
