# Configuración de Firebase para Subida de Imágenes

Este documento explica cómo configurar Firebase para permitir la subida de fotos de perfil desde la galería o cámara.

## ¿Por qué Firebase?

Firebase Storage se utiliza para almacenar las imágenes de perfil que los usuarios suben desde su dispositivo, ya que:
- Supabase Storage requiere configuración adicional y políticas de seguridad
- Firebase Storage es gratuito hasta 5GB de almacenamiento
- Integración sencilla con Flutter

## Pasos de Configuración

### 1. Crear un Proyecto en Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Agregar proyecto" o "Add project"
3. Ingresa el nombre de tu proyecto: `registro-docente` (o el nombre que prefieras)
4. Desactiva Google Analytics (opcional)
5. Haz clic en "Crear proyecto"

### 2. Configurar Firebase para Android

1. En la consola de Firebase, haz clic en el ícono de Android
2. Ingresa el nombre del paquete: `com.example.registrodocente`
   - **IMPORTANTE**: Verifica el nombre del paquete en `android/app/build.gradle`
3. (Opcional) Ingresa un apodo para la app
4. Descarga el archivo `google-services.json`
5. Coloca el archivo en: `android/app/google-services.json`
6. Edita `android/build.gradle` y agrega en dependencies:
   ```gradle
   classpath 'com.google.gms:google-services:4.4.0'
   ```
7. Edita `android/app/build.gradle` y agrega al final:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### 3. Configurar Firebase para iOS

1. En la consola de Firebase, haz clic en el ícono de iOS
2. Ingresa el Bundle ID desde `ios/Runner.xcodeproj/project.pbxproj`
   - Busca `PRODUCT_BUNDLE_IDENTIFIER`
3. Descarga el archivo `GoogleService-Info.plist`
4. Abre el proyecto en Xcode: `open ios/Runner.xcworkspace`
5. Arrastra `GoogleService-Info.plist` a la carpeta `Runner` en Xcode
   - Asegúrate de marcar "Copy items if needed"

### 4. Configurar Firebase para Web

1. En la consola de Firebase, haz clic en el ícono de Web (</>)
2. Registra tu app web
3. Copia la configuración de Firebase
4. Crea el archivo `web/firebase-config.js`:
   ```javascript
   // Import the functions you need from the SDKs you need
   import { initializeApp } from "firebase/app";

   // Your web app's Firebase configuration
   const firebaseConfig = {
     apiKey: "TU_API_KEY",
     authDomain: "tu-proyecto.firebaseapp.com",
     projectId: "tu-proyecto",
     storageBucket: "tu-proyecto.appspot.com",
     messagingSenderId: "123456789",
     appId: "1:123456789:web:abcdef"
   };

   // Initialize Firebase
   const app = initializeApp(firebaseConfig);
   ```
5. Agrega el script en `web/index.html` antes del tag `</body>`:
   ```html
   <script type="module" src="firebase-config.js"></script>
   ```

### 5. Habilitar Firebase Storage

1. En la consola de Firebase, ve a "Storage" en el menú lateral
2. Haz clic en "Comenzar" o "Get started"
3. Acepta las reglas de seguridad predeterminadas (modo de prueba)
4. Selecciona una ubicación para tu bucket (por ejemplo: `us-central1`)
5. Haz clic en "Listo"

### 6. Configurar Reglas de Seguridad

Por defecto, las reglas permiten acceso solo a usuarios autenticados. Para este proyecto:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_pictures/{userId} {
      // Permitir lectura pública de fotos de perfil
      allow read: if true;

      // Permitir escritura solo a usuarios autenticados
      allow write: if request.auth != null;
    }
  }
}
```

## Configuración Alternativa: FlutterFire CLI (Recomendado)

La forma más sencilla de configurar Firebase es usando FlutterFire CLI:

```bash
# 1. Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. Iniciar sesión en Firebase
firebase login

# 3. Configurar Firebase para tu proyecto
flutterfire configure
```

Este comando:
- Creará un proyecto en Firebase (o te permitirá seleccionar uno existente)
- Descargará automáticamente los archivos de configuración
- Generará el archivo `firebase_options.dart` con la configuración

Luego actualiza `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ... resto del código
}
```

## Verificar la Configuración

Para verificar que Firebase está correctamente configurado:

1. Ejecuta la app: `flutter run`
2. Busca en los logs: `✅ Firebase inicializado correctamente`
3. Intenta subir una foto de perfil
4. Verifica en Firebase Console > Storage que la imagen se haya subido

## Solución de Problemas

### Error: "FirebaseApp not initialized"
- Asegúrate de que `Firebase.initializeApp()` se llame antes de usar cualquier servicio
- Verifica que los archivos de configuración estén en las ubicaciones correctas

### Error: "Permission denied"
- Revisa las reglas de seguridad en Firebase Console > Storage > Rules
- Asegúrate de que el usuario esté autenticado (si las reglas lo requieren)

### Error en Android: "google-services.json not found"
- Verifica que el archivo esté en `android/app/google-services.json`
- Asegúrate de que `apply plugin: 'com.google.gms.google-services'` esté en `android/app/build.gradle`

### Error en iOS: "GoogleService-Info.plist not found"
- Abre el proyecto en Xcode
- Verifica que el archivo esté agregado al target `Runner`

## Recursos Adicionales

- [Documentación oficial de Firebase](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Storage Rules](https://firebase.google.com/docs/storage/security)
