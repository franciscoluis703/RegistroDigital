#!/bin/bash

echo "🚀 Desplegando a registrodigital.online con Firebase Hosting"
echo "============================================================="
echo ""

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar si Firebase CLI está instalado
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI no está instalado${NC}"
    echo ""
    echo "Para instalar, ejecuta:"
    echo "  npm install -g firebase-tools"
    echo ""
    exit 1
fi

# Verificar que estamos logueados en Firebase
echo -e "${BLUE}🔐 Verificando autenticación Firebase...${NC}"
if ! firebase projects:list &> /dev/null; then
    echo -e "${YELLOW}⚠️  No estás autenticado en Firebase${NC}"
    echo ""
    echo "Ejecutando firebase login..."
    firebase login
fi

echo ""
echo -e "${BLUE}🧹 Limpiando build anterior...${NC}"
flutter clean

echo ""
echo -e "${BLUE}📦 Obteniendo dependencias...${NC}"
flutter pub get

echo ""
echo -e "${BLUE}🌐 Building para Web...${NC}"
flutter build web --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build exitoso${NC}"
else
    echo -e "${RED}❌ Build falló${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🚀 Desplegando a Firebase Hosting...${NC}"
firebase deploy --only hosting

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ ¡Despliegue completado exitosamente!${NC}"
    echo ""
    echo "🌐 Tu aplicación está disponible en:"
    echo "   https://registro-docente-app.web.app"
    echo "   https://registrodigital.online (si el dominio está configurado)"
    echo ""
    echo "📋 Próximos pasos para configurar el dominio personalizado:"
    echo "   1. Ve a Firebase Console: https://console.firebase.google.com"
    echo "   2. Selecciona tu proyecto: registro-docente-app"
    echo "   3. Ve a Hosting > Domains"
    echo "   4. Haz clic en 'Add custom domain'"
    echo "   5. Ingresa: registrodigital.online"
    echo "   6. Sigue las instrucciones para actualizar los DNS"
    echo ""
else
    echo -e "${RED}❌ Despliegue falló${NC}"
    echo ""
    echo "Verifica:"
    echo "  1. Estás autenticado en Firebase: firebase login"
    echo "  2. El proyecto está configurado: firebase use registro-docente-app"
    echo ""
    exit 1
fi
