#!/bin/bash
echo Configurando linux ...

#Instalacion de dependencias y rustdesk
sudo apt install curl libva2 libva-drm2 libva-x11-2
wget https://github.com/rustdesk/rustdesk/releases/download/1.3.6/rustdesk-1.3.6-aarch64.deb
sudo dpkg -i rustdesk-1.3.6-aarch64.deb
rm rustdesk-1.3.6-aarch64.deb

#Crear el build de la aplicacion
sudo apt install node
npm i
npx electron-packager . monitortaller --platform=linux --arch=armv7l

# Ruta a la aplicación empaquetada
APP_PATH="./monitortaller-linux-arm64"
APP_EXEC="$APP_PATH/monitortaller"
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/monitor-taller.desktop"

# Verificar que la ruta de la aplicación exista
if [ ! -f "$APP_EXEC" ]; then
  echo "Error: La aplicación no se encontró en $APP_EXEC"
  exit 1
fi

# Crear el directorio autostart si no existe
mkdir -p "$AUTOSTART_DIR"

# Crear el archivo .desktop
cat <<EOL > "$DESKTOP_FILE"
[Desktop Entry]
Type=Application
Name=monitorTaller
Exec=$APP_EXEC
Terminal=false
EOL

# Establecer permisos
chmod +x "$DESKTOP_FILE"