#!/bin/bash

echo "🎯 Registro Docente - Build para Producción"
echo "=========================================="
echo ""

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 Limpiando proyecto...${NC}"
flutter clean
flutter pub get

echo ""
echo -e "${BLUE}📱 Building Android APK...${NC}"
flutter build apk --release
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ APK build exitoso${NC}"
else
    echo -e "${YELLOW}⚠️  APK build falló${NC}"
fi

echo ""
echo -e "${BLUE}📦 Building Android App Bundle...${NC}"
flutter build appbundle --release
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ App Bundle build exitoso${NC}"
else
    echo -e "${YELLOW}⚠️  App Bundle build falló${NC}"
fi

echo ""
echo -e "${BLUE}🌐 Building Web...${NC}"
flutter build web --release
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Web build exitoso${NC}"
else
    echo -e "${YELLOW}⚠️  Web build falló${NC}"
fi

echo ""
echo -e "${GREEN}✅ ¡Build completado!${NC}"
echo ""
echo "📍 Ubicaciones de archivos:"
echo "  📱 APK: build/app/outputs/flutter-apk/app-release.apk"
echo "  📦 AAB: build/app/outputs/bundle/release/app-release.aab"
echo "  🌐 Web: build/web/"
echo ""
echo "🚀 Para desplegar a registrodocente.online ejecuta:"
echo "   ./deploy_web.sh"
