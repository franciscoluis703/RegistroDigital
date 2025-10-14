# 🎨 Sistema de Diseño - Registro Docente (ClassDojo Style)

## Índice
1. [Introducción](#introducción)
2. [Filosofía de Diseño](#filosofía-de-diseño)
3. [Paleta de Colores](#paleta-de-colores)
4. [Tipografía](#tipografía)
5. [Componentes](#componentes)
6. [Logo y Branding](#logo-y-branding)
7. [Espaciado y Layout](#espaciado-y-layout)
8. [Iconografía](#iconografía)
9. [Animaciones](#animaciones)
10. [Guía de Uso](#guía-de-uso)

---

## Introducción

Este sistema de diseño está inspirado en **ClassDojo**, creando una experiencia visual cálida, vibrante y amigable pensada para entornos educativos. El objetivo es transmitir alegría, motivación y cercanía sin parecer infantil.

### Características principales:
- ✅ Colores vibrantes pero suaves (pastel con acentos brillantes)
- ✅ Tipografía redondeada y amigable (Nunito)
- ✅ Componentes con esquinas muy redondeadas
- ✅ Sombras suaves y sensación "flotante"
- ✅ Microanimaciones sutiles para feedback

---

## Filosofía de Diseño

### Principios fundamentales:

1. **Amigable pero profesional**
   - Diseño accesible para docentes de todas las edades
   - Colores cálidos que invitan a la interacción
   - Jerarquía visual clara

2. **Motivación y positividad**
   - Colores brillantes que celebran los logros
   - Feedback visual inmediato y positivo
   - Microanimaciones que hacen la experiencia más alegre

3. **Claridad y simplicidad**
   - Información organizada de manera intuitiva
   - Flujos de trabajo simples y directos
   - Texto legible y escaneable

---

## Paleta de Colores

### 🌈 Colores Principales

#### Azul Cielo (Primary)
- **Primario:** `#5B9FED`
- **Claro:** `#8BC4FF`
- **Oscuro:** `#2E7DD1`
- **Superficie:** `#E8F4FF`
- **Uso:** Acciones principales, enlaces, elementos interactivos

#### Verde Menta (Secondary)
- **Secundario:** `#6BCF8F`
- **Claro:** `#9BE2B0`
- **Oscuro:** `#4BA86F`
- **Superficie:** `#E7F9EE`
- **Uso:** Éxitos, confirmaciones, estados positivos

#### Naranja Alegre (Tertiary)
- **Terciario:** `#FFAB40`
- **Claro:** `#FFCC80`
- **Oscuro:** `#FF9100`
- **Superficie:** `#FFF3E0`
- **Uso:** Advertencias suaves, énfasis, llamadas a la acción

#### Violeta Mágico (Accent)
- **Acento:** `#B388FF`
- **Claro:** `#D1C4E9`
- **Oscuro:** `#7C4DFF`
- **Superficie:** `#F3E5F5`
- **Uso:** Elementos creativos, celebraciones, logros especiales

### 🎯 Colores Complementarios

#### Rosa Cálido
- **Rosa:** `#FF6B9D`
- **Claro:** `#FF8FB8`
- **Oscuro:** `#E91E63`
- **Superficie:** `#FCE4EC`

#### Amarillo Sol
- **Amarillo:** `#FFD54F`
- **Claro:** `#FFE57F`
- **Oscuro:** `#FFC107`
- **Superficie:** `#FFFDE7`

### ✅ Estados Semánticos

| Estado | Color | Hex | Uso |
|--------|-------|-----|-----|
| Éxito | Verde Menta | `#6BCF8F` | Completado, aprobado, correcto |
| Advertencia | Naranja | `#FFAB40` | Atención, pendiente |
| Error | Rojo Suave | `#FF6B6B` | Error, incorrecto, eliminado |
| Información | Azul Cielo | `#5B9FED` | Notas, consejos, ayuda |

### 🎭 Neutrales y Texto

| Uso | Color | Hex |
|-----|-------|-----|
| Texto Principal | Gris Oscuro Cálido | `#2D3748` |
| Texto Secundario | Gris Medio | `#718096` |
| Texto Terciario | Gris Claro | `#A0AEC0` |
| Texto Deshabilitado | Gris Muy Claro | `#CBD5E0` |
| Fondo Principal | Casi Blanco Azulado | `#F7FAFC` |
| Superficie | Blanco | `#FFFFFF` |
| Divisores | Gris Claro Bordes | `#E2E8F0` |

### 🎓 Colores Temáticos Educativos

| Módulo | Color | Hex | Superficie |
|--------|-------|-----|-----------|
| Asistencia | Verde | `#6BCF8F` | `#E7F9EE` |
| Calificaciones | Azul | `#5B9FED` | `#E8F4FF` |
| Promoción | Violeta | `#B388FF` | `#F3E5F5` |
| Datos Generales | Naranja | `#FFAB40` | `#FFF3E0` |
| Calendario | Rosa | `#FF6B9D` | `#FCE4EC` |
| Horario | Amarillo | `#FFD54F` | `#FFFDE7` |
| Evidencias | Teal | `#26A69A` | `#E0F2F1` |
| Notas | Índigo | `#5C6BC0` | `#E8EAF6` |

### 🌟 Gradientes Decorativos

```dart
// Gradiente Primario (Azul)
LinearGradient(
  colors: [Color(0xFF5B9FED), Color(0xFF8BC4FF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// Gradiente Secundario (Verde)
LinearGradient(
  colors: [Color(0xFF6BCF8F), Color(0xFF9BE2B0)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// Gradiente de Celebración (Rosa a Naranja)
LinearGradient(
  colors: [Color(0xFFFF6B9D), Color(0xFFFFAB40)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// Gradiente Mágico (Violeta a Azul)
LinearGradient(
  colors: [Color(0xFFB388FF), Color(0xFF5B9FED)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

---

## Tipografía

### Fuente Principal: Nunito

**Nunito** es una fuente sans-serif redondeada y amigable, perfecta para entornos educativos.

#### Configuración en Flutter:
```yaml
# pubspec.yaml
dependencies:
  google_fonts: ^6.2.1
```

```dart
// Uso en código
import 'package:google_fonts/google_fonts.dart';

Text(
  'Hola Docente',
  style: GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w800,
  ),
);
```

### Jerarquía Tipográfica

#### Display (Títulos muy grandes - Splash, Bienvenida)
- **Display Large:** 48px, weight 900
- **Display Medium:** 40px, weight 900
- **Display Small:** 36px, weight 800

#### Headlines (Títulos de secciones)
- **Headline Large:** 32px, weight 800
- **Headline Medium:** 28px, weight 800
- **Headline Small:** 24px, weight 700

#### Titles (Títulos de cards y elementos)
- **Title Large:** 20px, weight 700
- **Title Medium:** 17px, weight 700
- **Title Small:** 15px, weight 700

#### Body (Texto de contenido)
- **Body Large:** 17px, weight 500
- **Body Medium:** 15px, weight 500
- **Body Small:** 13px, weight 500

#### Labels (Etiquetas y botones)
- **Label Large:** 15px, weight 700
- **Label Medium:** 13px, weight 700
- **Label Small:** 11px, weight 700

### Pesos de Fuente (Weights)
- **Regular:** 400 (w400)
- **Medium:** 500 (w500)
- **SemiBold:** 600 (w600)
- **Bold:** 700 (w700)
- **ExtraBold:** 800 (w800)
- **Black:** 900 (w900)

---

## Componentes

### 🔘 DojoButton

Botón vibrante con esquinas muy redondeadas y efectos de presión.

#### Estilos disponibles:
- `primary` - Azul con gradiente
- `secondary` - Verde con gradiente
- `success` - Verde éxito
- `warning` - Naranja advertencia
- `outlined` - Borde sin relleno
- `text` - Sin fondo

#### Tamaños:
- `small` - 40px altura
- `medium` - 54px altura (default)
- `large` - 64px altura

#### Ejemplo de uso:
```dart
DojoButton(
  text: 'Iniciar Sesión',
  icon: Icons.login,
  style: DojoButtonStyle.primary,
  size: DojoButtonSize.medium,
  isFullWidth: true,
  onPressed: () {
    // Acción
  },
)
```

### 🎴 DojoCard

Tarjeta con esquinas muy redondeadas (20px) y sombras suaves.

#### Estilos disponibles:
- `normal` - Blanco estándar
- `primary` - Fondo azul suave
- `secondary` - Fondo verde suave
- `success` - Fondo verde éxito
- `warning` - Fondo naranja
- `error` - Fondo rojo
- `gradient` - Gradiente azul
- `celebration` - Gradiente celebración

#### Ejemplo de uso:
```dart
DojoCard(
  style: DojoCardStyle.primary,
  onTap: () {
    // Acción
  },
  child: Column(
    children: [
      Text('Título'),
      Text('Contenido'),
    ],
  ),
)
```

### 📝 DojoInput

Campo de texto con bordes redondeados y feedback visual claro.

#### Características:
- Animación de borde al hacer focus
- Sombra suave cuando está activo
- Soporte para íconos prefix/suffix
- Validación con colores semánticos

#### Ejemplo de uso:
```dart
DojoInput(
  label: 'Correo Electrónico',
  hint: 'tu@correo.com',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  controller: emailController,
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'Campo requerido';
    }
    return null;
  },
)
```

---

## Logo y Branding

### 📚 Logo Principal

**Concepto:** Libro abierto digital con estrella de excelencia

#### Elementos del logo:
1. **Libro abierto** (dos páginas)
   - Página izquierda: Azul `#5B9FED`
   - Página derecha: Verde `#6BCF8F`
   - Líneas de texto blancas simulando contenido

2. **Estrella de excelencia**
   - Color: Amarillo `#FFD54F`
   - Borde: Naranja `#FFAB40`
   - Representa logros y calidad educativa

3. **Tipografía:**
   - "Registro" en gris oscuro `#2D3748`
   - "Docente" en azul primario `#5B9FED`
   - Font: Nunito ExtraBold (800)

### Versiones del logo:

#### Logo Horizontal
- **Ubicación:** `/assets/logo/logo_horizontal.svg`
- **Uso:** Headers, pantallas de bienvenida, emails
- **Dimensiones:** 240x60px

#### Logo Ícono (Cuadrado)
- **Ubicación:** `/assets/logo/logo_icon.svg`
- **Uso:** App icon, favicon, notificaciones
- **Dimensiones:** 120x120px

### Reglas de uso:
- ✅ Usar sobre fondos claros (blanco o `#F7FAFC`)
- ✅ Mantener espacio libre alrededor (min 20px)
- ✅ No distorsionar las proporciones
- ❌ No cambiar los colores del logo
- ❌ No agregar efectos (sombras, gradientes externos)
- ❌ No rotar el logo

---

## Espaciado y Layout

### Sistema de Espaciado (8px grid)

| Nombre | Valor | Uso |
|--------|-------|-----|
| `xs` | 4px | Espacios muy pequeños |
| `sm` | 8px | Espacios pequeños entre elementos relacionados |
| `md` | 16px | Espaciado estándar |
| `lg` | 24px | Espaciado entre secciones |
| `xl` | 32px | Espaciado grande |
| `2xl` | 48px | Espaciado muy grande |
| `3xl` | 64px | Espaciado máximo |

### Bordes Redondeados

| Nombre | Radio | Uso |
|--------|-------|-----|
| `sm` | 8px | Chips, badges |
| `md` | 12px | Inputs alternativos |
| `lg` | 16px | Inputs, chips grandes |
| `xl` | 20px | Cards |
| `2xl` | 24px | Diálogos |
| `3xl` | 28px | Botones, elementos destacados |
| `full` | 9999px | Círculos perfectos |

### Elevación (Sombras)

```dart
// Elevación Baja (Cards en reposo)
BoxShadow(
  color: Colors.black.withValues(alpha: 0.08),
  blurRadius: 8,
  offset: Offset(0, 2),
)

// Elevación Media (Cards hover)
BoxShadow(
  color: Colors.black.withValues(alpha: 0.12),
  blurRadius: 16,
  offset: Offset(0, 4),
)

// Elevación Alta (Diálogos, Modales)
BoxShadow(
  color: Colors.black.withValues(alpha: 0.16),
  blurRadius: 24,
  offset: Offset(0, 8),
)
```

---

## Iconografía

### Librería de Íconos

Usamos **Material Icons** de Flutter con los siguientes estilos:

#### Íconos Principales (24px)
- **Navegación:** `Icons.home`, `Icons.school`, `Icons.person`
- **Acciones:** `Icons.add`, `Icons.edit`, `Icons.delete`
- **Estados:** `Icons.check_circle`, `Icons.warning`, `Icons.error`

#### Íconos Temáticos:
- **Asistencia:** `Icons.how_to_reg`, `Icons.event_available`
- **Calificaciones:** `Icons.grading`, `Icons.assessment`
- **Calendario:** `Icons.calendar_today`, `Icons.event`
- **Notas:** `Icons.notes`, `Icons.description`
- **Evidencias:** `Icons.photo_library`, `Icons.attach_file`

### Colores de íconos:
- **Inactivo:** `#718096` (textSecondary)
- **Activo:** `#5B9FED` (primary)
- **En superficie primaria:** `#FFFFFF` (white)

---

## Animaciones

### Principios de Animación

1. **Sutileza:** Las animaciones deben ser suaves y no distraer
2. **Rapidez:** Duraciones cortas (150-300ms)
3. **Propósito:** Cada animación debe comunicar algo

### Duraciones Estándar

| Tipo | Duración | Curva | Uso |
|------|----------|-------|-----|
| Micro | 150ms | `easeOut` | Hover, press |
| Corta | 200ms | `easeInOut` | Transiciones simples |
| Media | 300ms | `easeInOut` | Expansión de cards |
| Larga | 400ms | `easeOut` | Navegación entre pantallas |

### Efectos Comunes

#### 1. Botón Press (Scale Down)
```dart
AnimationController(duration: Duration(milliseconds: 150))
Tween<double>(begin: 1.0, end: 0.95)
CurvedAnimation(curve: Curves.easeInOut)
```

#### 2. Card Hover (Elevate + Scale)
```dart
AnimationController(duration: Duration(milliseconds: 200))
// Elevation: 3 → 7
// Scale: 1.0 → 1.02
```

#### 3. Input Focus (Border Pulse)
```dart
AnimationController(duration: Duration(milliseconds: 200))
// Border width: 2.0 → 2.5
// Shadow blur: 0 → 12
```

---

## Guía de Uso

### Aplicar el Tema

```dart
import 'package:flutter/material.dart';
import 'app/presentation/themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro Docente',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
```

### Usar Colores del Sistema

```dart
import 'app/presentation/themes/app_colors.dart';

// Color directo
Container(color: AppColors.primary)

// Color con opacidad
Container(color: AppColors.withOpacity(AppColors.primary, 0.5))

// Gradiente
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
  ),
)
```

### Usar Tipografía del Sistema

```dart
// Desde el tema
Text(
  'Título',
  style: Theme.of(context).textTheme.headlineLarge,
)

// Personalizado con Nunito
Text(
  'Botón',
  style: GoogleFonts.nunito(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  ),
)
```

### Estructura de Pantalla Recomendada

```dart
Scaffold(
  backgroundColor: AppColors.background,
  appBar: AppBar(
    title: Text('Título'),
  ),
  body: SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        DojoCard(
          child: // Contenido
        ),
        SizedBox(height: 16),
        DojoButton(
          text: 'Acción',
          onPressed: () {},
        ),
      ],
    ),
  ),
)
```

---

## Recursos

### Archivos del Sistema:
- **Paleta de colores:** `/lib/app/presentation/themes/app_colors.dart`
- **Tema principal:** `/lib/app/presentation/themes/app_theme.dart`
- **Widgets personalizados:** `/lib/app/presentation/widgets/common/`
- **Logos:** `/assets/logo/`

### Herramientas Recomendadas:
- **Figma:** Para mockups y prototipos
- **ColorSlurp:** Para extraer colores
- **Flutter Inspector:** Para debug visual

### Referencias:
- [ClassDojo](https://www.classdojo.com/) - Inspiración visual
- [Material Design 3](https://m3.material.io/) - Guías de componentes
- [Google Fonts - Nunito](https://fonts.google.com/specimen/Nunito)

---

## Contacto y Contribuciones

Para sugerencias o mejoras al sistema de diseño, contactar al equipo de desarrollo.

**Versión:** 1.0.0
**Última actualización:** Octubre 2025
**Licencia:** Uso exclusivo para Registro Docente
