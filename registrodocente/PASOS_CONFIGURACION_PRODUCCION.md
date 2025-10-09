# Pasos para Configurar Producción en registrodigital.online

## ✅ Pasos Completados

1. ✅ **Build de producción** - La aplicación web se compiló exitosamente
2. ✅ **Despliegue a Firebase Hosting** - La app está desplegada en: https://registro-docente-app.web.app

## 🔧 Pasos Pendientes (Configuración Manual)

### 1. Configurar Dominio Personalizado en Firebase

Debes seguir estos pasos en la consola de Firebase:

1. **Ir a Firebase Console**:
   - URL: https://console.firebase.google.com/project/registro-docente-app/hosting

2. **Agregar dominio personalizado**:
   - Click en "Agregar dominio personalizado"
   - Ingresar: `registrodigital.online`
   - Firebase te dará registros DNS para configurar

3. **Configurar DNS** (en tu proveedor de dominio):
   Firebase te proporcionará algo como:
   ```
   Tipo: A
   Nombre: @
   Valor: 151.101.1.195, 151.101.65.195

   Tipo: TXT
   Nombre: @
   Valor: [código de verificación de Firebase]
   ```

4. **Esperar verificación**:
   - Puede tomar hasta 24 horas
   - Firebase configurará automáticamente HTTPS

### 2. Habilitar Firebase Authentication

**IMPORTANTE**: Actualmente la app usa Supabase para autenticación, NO Firebase Auth.

Si quieres cambiar a Firebase Auth:

1. **Ir a Authentication en Firebase Console**:
   - URL: https://console.firebase.google.com/project/registro-docente-app/authentication

2. **Habilitar métodos de autenticación**:
   - Click en "Get Started"
   - Habilitar "Email/Password"
   - Configurar dominio autorizado: `registrodigital.online`

3. **Actualizar código** para usar Firebase Auth en lugar de Supabase

### 3. Configurar Supabase (Método Actual)

La app actualmente usa Supabase. Necesitas:

1. **Verificar que Supabase esté configurado**:
   - Archivo: `lib/app/config/supabase_config.dart`
   - Debe tener las credenciales correctas

2. **Configurar Redirect URLs en Supabase**:
   - Ir a: https://supabase.com/dashboard
   - Tu proyecto → Authentication → URL Configuration
   - Agregar URLs autorizadas:
     - `https://registrodigital.online/**`
     - `https://registro-docente-app.web.app/**`

3. **Verificar políticas RLS**:
   - Las tablas deben tener políticas de Row Level Security configuradas
   - Ver archivo: `database/supabase_schema.sql`

### 4. Actualizar authDomain en el Código

Una vez el dominio esté configurado, actualizar:

**Archivo**: `lib/firebase_options.dart`

Cambiar línea 48:
```dart
authDomain: 'registrodigital.online',  // En lugar de 'registro-docente-app.firebaseapp.com'
```

Luego rebuild y redeploy:
```bash
flutter build web --release
firebase deploy --only hosting
```

## 🔍 Verificar Configuración Actual

### Supabase Config
Verificar archivo: `lib/app/config/supabase_config.dart`

### Rutas Disponibles
- ✅ `/login` - Pantalla de login con Supabase
- ✅ `/sign-up` - Registro de nuevos usuarios
- ✅ `/forgot-password` - Recuperar contraseña
- ✅ `/home` - Pantalla principal (requiere autenticación)

### Flujo de Autenticación Actual
1. App inicia → SplashView
2. Verifica autenticación de Supabase
3. Si autenticado → Home
4. Si NO autenticado → Login

## 📋 Comandos Útiles

### Ver sitios de hosting
```bash
firebase hosting:sites:list
```

### Desplegar de nuevo
```bash
flutter build web --release
firebase deploy --only hosting
```

### Ver logs de Firebase
```bash
firebase hosting:channel:list
```

## 🌐 URLs de la Aplicación

- **Firebase Hosting**: https://registro-docente-app.web.app
- **Dominio personalizado** (pendiente configuración): https://registrodigital.online
- **Console Firebase**: https://console.firebase.google.com/project/registro-docente-app/overview

## ⚠️ Notas Importantes

1. **Supabase vs Firebase Auth**: La app usa Supabase para autenticación, no Firebase Authentication
2. **HTTPS Automático**: Firebase maneja SSL automáticamente cuando configures el dominio
3. **Caché de DNS**: Cambios de DNS pueden tomar 24-48 horas en propagarse
4. **Variables de entorno**: Asegúrate de que las credenciales de Supabase estén configuradas correctamente

## 🔐 Seguridad

- ✅ Headers de seguridad configurados en `firebase.json`
- ✅ HTTPS forzado
- ⚠️ Verificar que las credenciales de Supabase NO estén expuestas en el repositorio público
- ⚠️ Configurar RLS (Row Level Security) en todas las tablas de Supabase
