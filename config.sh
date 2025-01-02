#!/bin/bash
echo Configurando linux ...

#Instalacion de dependencias y rustdesk
sudo apt install curl libva2 libva-drm2 libva-x11-2
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

#Config ip network
read -p "¿Quieres configurar la red? (s/n): " answer

if [[ "$answer" == "s" ]]; then
    echo "Configuración de red IPv4 estática:"
    
    # Pedir los parámetros necesarios
    read -p "Ingresa la IP: " ip_address
    read -p "Ingresa la Netmask: " netmask
    read -p "Ingresa la Gateway: " gateway
    read -p "Ingresa el DNS (separado por comas si hay más de uno): " dns

    # Obtener el nombre de la interfaz de red
    interface=$(ip -o link show | awk -F': ' '{print $2}' | grep -E "en|eth" | head -n 1)

    if [[ -z "$interface" ]]; then
        echo "No se detectó ninguna interfaz de red con cable. Asegúrate de que esté conectada."
        exit 1
    fi

    echo "Configurando la interfaz $interface con los siguientes parámetros:"
    echo "IP: $ip_address"
    echo "Netmask: $netmask"
    echo "Gateway: $gateway"
    echo "DNS: $dns"

    # Crear archivo de configuración temporal para NetworkManager
    config_file="/etc/NetworkManager/system-connections/$interface.nmconnection"
    sudo tee "$config_file" > /dev/null <<EOL
[connection]
id=$interface
uuid=$(uuidgen)
type=ethernet
interface-name=$interface

[ipv4]
address1=$ip_address/$netmask,$gateway
dns=$dns
method=manual

[ipv6]
method=ignore
EOL

    # Aplicar los cambios
    sudo chmod 600 "$config_file"
    sudo systemctl restart NetworkManager
fi
