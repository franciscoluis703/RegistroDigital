# 🌐 Configuración del Dominio registrodigital.online

## Estado Actual

- **Proyecto Firebase**: `registro-docente-app`
- **URL Firebase**: https://registro-docente-app.web.app
- **Dominio Personalizado**: registrodigital.online

## Pasos para Configurar el Dominio Personalizado

### 1. Acceder a Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona el proyecto: **registro-docente-app**
3. En el menú lateral, ve a **Hosting**
4. Haz clic en la pestaña **Domains**

### 2. Agregar Dominio Personalizado

1. Haz clic en **Add custom domain**
2. Ingresa: `registrodigital.online`
3. Haz clic en **Continue**

### 3. Verificar Propiedad del Dominio

Firebase te pedirá que agregues un registro TXT a tu DNS para verificar la propiedad:

```
Tipo: TXT
Nombre: @
Valor: [valor proporcionado por Firebase]
TTL: 3600
```

### 4. Configurar Registros DNS

Una vez verificado el dominio, deberás agregar los siguientes registros DNS:

#### Para el dominio raíz (registrodigital.online):

```
Tipo: A
Nombre: @
Valor: [IP proporcionada por Firebase]
TTL: 3600
```

#### Para www (opcional):

```
Tipo: CNAME
Nombre: www
Valor: registro-docente-app.web.app
TTL: 3600
```

### 5. Esperar Propagación DNS

- La propagación DNS puede tardar entre 5 minutos y 48 horas
- Firebase configurará automáticamente el certificado SSL (HTTPS)
- Puedes verificar el estado en Firebase Console

## Script de Despliegue

Usa el script automatizado para desplegar:

```bash
./scripts/deploy_firebase.sh
```

## Configuración de Firebase Hosting

El archivo `firebase.json` ya está configurado con:

✅ **Rewrites**: Para SPA (Single Page Application)
✅ **Security Headers**: X-Content-Type-Options, X-Frame-Options, X-XSS-Protection
✅ **Cache Control**: Optimizado para archivos estáticos

## Verificación Post-Despliegue

Después de configurar el dominio, verifica:

1. **HTTPS habilitado**: https://registrodigital.online
2. **Redirección HTTP → HTTPS**: Automática con Firebase
3. **Headers de seguridad**: Verifica con herramientas como [Security Headers](https://securityheaders.com)
4. **Performance**: Verifica con [PageSpeed Insights](https://pagespeed.web.dev)

## Comandos Útiles

```bash
# Ver proyectos de Firebase
firebase projects:list

# Ver sitios de hosting
firebase hosting:sites:list

# Desplegar solo hosting
firebase deploy --only hosting

# Ver logs de hosting
firebase hosting:clone registro-docente-app:live hosting:temp
```

## Integración con Supabase

El dominio funcionará correctamente con Supabase ya que:

- ✅ Las variables de entorno están configuradas en `.env`
- ✅ Las políticas RLS están habilitadas
- ✅ La autenticación está configurada
- ✅ El CORS está permitido para el dominio

### Configurar el dominio en Supabase:

1. Ve a [Supabase Dashboard](https://app.supabase.com)
2. Selecciona tu proyecto
3. Ve a **Authentication** → **URL Configuration**
4. Agrega a **Site URL**: `https://registrodigital.online`
5. Agrega a **Redirect URLs**: `https://registrodigital.online/**`

## Soporte

Si tienes problemas:

1. Verifica los logs de Firebase: `firebase hosting:channel:list`
2. Verifica la configuración DNS con: `nslookup registrodigital.online`
3. Verifica el certificado SSL con: `openssl s_client -connect registrodigital.online:443`

## Referencias

- [Firebase Hosting Docs](https://firebase.google.com/docs/hosting)
- [Custom Domain Setup](https://firebase.google.com/docs/hosting/custom-domain)
- [Supabase URL Configuration](https://supabase.com/docs/guides/auth/redirect-urls)
