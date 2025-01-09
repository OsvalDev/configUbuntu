#!/bin/bash
echo Configurando linux ...

#Instalacion de dependencias y rustdesk
sudo apt install curl libva2 libva-drm2 libva-x11-2 libxdo3
wget https://github.com/rustdesk/rustdesk/releases/download/1.3.6/rustdesk-1.3.6-aarch64.deb
sudo dpkg -i rustdesk-1.3.6-aarch64.deb
rm rustdesk-1.3.6-aarch64.deb

#Crear el build de la aplicacion
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 22
nvm use 22
npm i
npx electron-packager . monitortaller --platform=linux --arch=arm64

# Ruta a la aplicación empaquetada
APP_PATH="$HOME/configUbuntu/monitortaller-linux-arm64"
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
Exec=$APP_EXEC --no-sandbox
Terminal=false
EOL

# Establecer permisos
chmod +x "$DESKTOP_FILE"
