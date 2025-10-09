# PASO 1: Configurar Supabase

## 1.1 Crear Proyecto en Supabase

1. Ve a: https://supabase.com/
2. Haz clic en **"Start your project"** o **"Sign in"**
3. Inicia sesión con GitHub o Google
4. Haz clic en **"New Project"**

### Configuración del Proyecto:
- **Name:** registro-docente
- **Database Password:** [Crea una contraseña fuerte y guárdala]
- **Region:** South America (sa-east-1) - Más cercano a República Dominicana
- **Pricing Plan:** Free (perfecto para empezar)

5. Haz clic en **"Create new project"**
6. Espera 1-2 minutos mientras se crea el proyecto

## 1.2 Obtener Credenciales

Una vez creado el proyecto:

1. Ve a **Settings** (⚙️) en el menú lateral
2. Clic en **API**
3. Copia y guarda estos valores (los necesitaremos después):

```
Project URL: https://[tu-proyecto].supabase.co
anon public key: eyJ... (clave larga)
service_role key: eyJ... (clave larga - SECRETA)
```

**⚠️ IMPORTANTE:** Nunca compartas el `service_role key` públicamente.

## 1.3 Ejecutar Script SQL

1. En el menú lateral de Supabase, haz clic en **SQL Editor**
2. Haz clic en **"+ New query"**
3. Abre el archivo `supabase_persistencia_completa.sql` que está en la raíz del proyecto
4. Copia TODO el contenido del archivo
5. Pégalo en el editor SQL de Supabase
6. Haz clic en **"Run"** (▶️) en la esquina inferior derecha

### Verificar que funcionó:

1. Ve a **Table Editor** en el menú lateral
2. Deberías ver estas tablas:
   - profiles
   - cursos
   - estudiantes
   - asistencia
   - calificaciones
   - promocion_grado
   - horarios
   - user_activity_logs
   - sync_queue

3. Haz clic en cualquier tabla
4. Ve a la pestaña **"Policies"**
5. Deberías ver políticas RLS activas (ícono de candado 🔒 verde)

## 1.4 Configurar Autenticación

1. Ve a **Authentication** en el menú lateral
2. Haz clic en **Providers**
3. Verifica que **Email** esté habilitado (debería estarlo por defecto)

### (Opcional) Configurar Google OAuth:

Si quieres permitir login con Google:

1. En **Providers**, habilita **Google**
2. Necesitarás crear credenciales en Google Cloud Console
3. Por ahora, puedes dejarlo deshabilitado y solo usar email/contraseña

## 1.5 Configurar Email Templates (Opcional pero Recomendado)

1. Ve a **Authentication** > **Email Templates**
2. Personaliza los templates de:
   - Confirm Signup
   - Reset Password
   - Magic Link

Por ejemplo, para "Confirm Signup":
```
Subject: Confirma tu registro en Registro Docente

Hola,

Gracias por registrarte en Registro Docente.

Por favor confirma tu correo electrónico haciendo clic en el siguiente enlace:

{{ .ConfirmationURL }}

Si no solicitaste esta cuenta, puedes ignorar este email.

Saludos,
Equipo Registro Docente
```

## ✅ Verificación Final

- [ ] Proyecto Supabase creado
- [ ] Credenciales copiadas y guardadas
- [ ] Script SQL ejecutado sin errores
- [ ] Tablas visibles en Table Editor
- [ ] RLS habilitado en todas las tablas
- [ ] Email provider habilitado

**Una vez completado esto, continúa con el PASO 2.**
