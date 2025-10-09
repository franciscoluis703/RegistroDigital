# 🌐 Pasos para Configurar registrodigital.online

## ✅ Completado

1. ✅ App desplegada en producción: https://registro-docente-app.web.app
2. ✅ Firebase Hosting configurado con headers de seguridad
3. ✅ Build optimizado para producción

## 📋 Siguientes Pasos (Debes hacerlos manualmente)

### Paso 1: Agregar el Dominio en Firebase Console

1. **Abre Firebase Console**:
   - Ve a: https://console.firebase.google.com/project/registro-docente-app/hosting/main
   - O busca tu proyecto: **registro-docente-app**

2. **Navega a Hosting → Domains**:
   - En el menú lateral, haz clic en **Hosting**
   - Luego haz clic en la pestaña **Domains** (Dominios)

3. **Agrega el dominio personalizado**:
   - Haz clic en el botón **Add custom domain** (Agregar dominio personalizado)
   - Ingresa: `registrodigital.online`
   - Haz clic en **Continue** (Continuar)

### Paso 2: Verificar la Propiedad del Dominio

Firebase te mostrará un registro TXT que debes agregar a tu DNS:

**Ejemplo de registro TXT:**
```
Tipo: TXT
Nombre: @ (o registrodigital.online)
Valor: google-site-verification=XXXXXXXXXXXXXX
TTL: 3600
```

**Dónde agregar esto:**
- Ve al panel de control de tu proveedor de dominios (donde compraste registrodigital.online)
- Busca la sección de **DNS Management** o **DNS Settings**
- Agrega el registro TXT que te dio Firebase
- Espera unos minutos y haz clic en **Verify** en Firebase Console

### Paso 3: Configurar los Registros DNS

Después de verificar el dominio, Firebase te dará las direcciones IP para apuntar tu dominio:

**Registros A que debes agregar:**
```
Tipo: A
Nombre: @
Valor: 151.101.1.195
TTL: 3600

Tipo: A
Nombre: @
Valor: 151.101.65.195
TTL: 3600
```

**IMPORTANTE**: Firebase te dará las IPs exactas. Usa las que aparezcan en tu consola.

**Opcional - Para www:**
```
Tipo: CNAME
Nombre: www
Valor: registro-docente-app.web.app
TTL: 3600
```

### Paso 4: Esperar la Propagación

1. **Tiempo de espera**:
   - Mínimo: 5-10 minutos
   - Máximo: 48 horas (generalmente menos de 2 horas)

2. **Firebase configurará automáticamente**:
   - ✅ Certificado SSL (HTTPS)
   - ✅ Redirección HTTP → HTTPS
   - ✅ Redirección www → dominio principal

3. **Verificar el estado**:
   - En Firebase Console verás el estado del dominio
   - Cuando diga "Connected" (Conectado), estará listo

### Paso 5: Actualizar Supabase

Una vez que el dominio esté activo:

1. Ve a: https://app.supabase.com
2. Selecciona tu proyecto
3. Ve a **Authentication** → **URL Configuration**
4. Actualiza:
   - **Site URL**: `https://registrodigital.online`
   - **Redirect URLs**: Agrega `https://registrodigital.online/**`

## 🔍 Verificación

Cuando todo esté listo, verifica:

```bash
# Ver el DNS actual
nslookup registrodigital.online

# Probar HTTPS
curl -I https://registrodigital.online

# Ver headers de seguridad
curl -I https://registrodigital.online | grep -i "x-"
```

## ⚠️ Notas Importantes

1. **Elimina los registros DNS antiguos** de registrodigital.online antes de agregar los nuevos de Firebase
2. **No elimines el dominio** de Firebase Console una vez agregado, o perderás el SSL
3. **El certificado SSL** se renueva automáticamente cada 90 días

## 📞 Ayuda

Si tienes problemas:

1. Verifica que los registros DNS estén correctos en tu proveedor
2. Espera al menos 1 hora para propagación
3. Revisa Firebase Console para mensajes de error
4. Contacta al soporte de Firebase si es necesario

## 🎉 Resultado Final

Cuando todo esté configurado:

- ✅ https://registrodigital.online → Tu app en producción
- ✅ https://www.registrodigital.online → Redirige a registrodigital.online
- ✅ http://registrodigital.online → Redirige a HTTPS
- ✅ Certificado SSL válido y renovación automática
- ✅ Headers de seguridad configurados
- ✅ Integración con Supabase funcionando
