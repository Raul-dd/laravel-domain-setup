#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n${redColour}[!] Saliendo...${endColour}"
  exit 1
}

function helpPanel(){
  echo -e "\n${yellowColour}[+] Uso:${endColour}\n"
  echo -e "\t${blueColour}-s)${endColour}${grayColour} Especificar el servidor web (apache, nginx)${endColour}"
  echo -e "\t${blueColour}-h)${endColour}${grayColour} Panel de ayuda${endColour}\n"
}

function set_laravel_permissions(){
  echo -e "Configurando permisos optimizados para laravel..."
  
  local DIR="$PROJECT"
  while [ "$DIR" != "/" ]; do
      chmod o+x "$DIR" 2>/dev/null
      DIR=$(dirname "$DIR")
  done

  local WEB_GROUP=""
  if [ "$SERVICE_NAME" == "xampp" ]; then
    WEB_GROUP="daemon"
  elif getent group http >/dev/null 2>&1; then
    WEB_GROUP="http"
  elif getent group www-data >/dev/null 2>&1; then
    WEB_GROUP="www-data"
  elif getent group apache >/dev/null 2>&1; then
    WEB_GROUP="apache"
  elif getent group www >/dev/null 2>&1; then
    WEB_GROUP="www"
  else
    WEB_GROUP="nobody"
  fi

  echo "Using web server group: $WEB_GROUP"

  sudo chown -R $USER:$WEB_GROUP "$PROJECT"

  sudo find "$PROJECT" -type d -exec chmod 755 {} \;
  sudo find "$PROJECT" -type f -exec chmod 644 {} \;

  if [ -d "$PROJECT/storage" ]; then
      sudo chmod -R 775 "$PROJECT/storage" "$PROJECT/bootstrap/cache"
  fi

  

  if command -V systemctl >/dev/null 2>&1; then
      local SYSTEM_SERVER=""
      [[ "$WEB_GROUP" == "http" ]] && SYSTEM_SERVER="http"
      [[ "$WEB_GROUP" == "www-data" || "$WEB_GROUP" == "apache" ]] && SYSTEM_SERVER="apache2"
      
      if [[ -n "$SYSTEM_SERVER" ]] && systemctl list-unit-files | grep -q "${SYSTEM_SERVER}.service"; then
          echo -e "Anulando restriccion ProtectoraHome en Systemd para $SYSTEM_SERVER..."
          sudo mkdir -p /etc/systemd/system/${SYSTEM_SERVER}.service.d/
          echo -e "[Service]\nProtectHome=off" | sudo tee /etc/systemd/system/${SYSTEM_SERVER}.service.d/override.conf > /dev/null
          sudo systemctl daemon-reload
          sudo systemctl restart "$SYSTEM_SERVER"
      fi
  fi
}

PROJECT="$(pwd)"

function checkServer(){
  case "$server" in
    apache)
      if ! command -V httpd >/dev/null 2>&1; then
        echo -e "\n${redColour}[!] Error: Apache no esta instalado.${endColour}\n"
        exit 1
      fi
      echo -e "\n${yellowColour}[+] Apache encontrado\n${endColour}"
      
      if ! systemctl is-active --quiet httpd; then
        echo -e "[!] Error: Apache no esta ejecutandose."
        echo -e "[+] Inicia Apache con: sudo systemctl start httpd"
        exit 1
      fi
      
      echo -e "[+] Apache esta activo"
      sleep 2
    ;;
    nginx)
      if ! command -V nginx >/dev/null 2>&1; then
        echo -e "\n${redColour}[!] Error: Nginx no esta instalado.${endColour}\n"
        exit 1
      fi
      echo -e "\n${yellowColour}[+] Nginx encontrado\n${endColour}"
       if ! systemctl is-active --quiet nginx; then
        echo -e "[!] Error: Nginx no esta ejecutandose."
        echo -e "[+] Inicia Nginx con: sudo systemctl start nginx"
        exit 1
      fi
      
      echo -e "[+] Apache esta activo"

      sleep 2
    ;;
    *)
      echo -e "\n${redColour}[!] ERROR${endColour}\n"
    ;;
  esac
}

function checkOS(){
   OS="$(uname -s)"
   if [ "$OS" != "Linux" ]; then
      echo -e "\n${redColour}[!] Error: este sript actual solo soporta Linux\n${endColour}"
      exit 1
   fi
   echo -e "\n${yellowColour}[+] Sistema operativo Linux\n${endColour}"
   sleep 2
}

function isLaravelProject(){
  if [ ! -f "$PROJECT/artisan" ]; then
    echo -e "\n${redColour}[!] Error: no se encontro el archivo artisan.${endColour}\n"
    echo -e "${redColour}[?]El proyecto no parece ser un proyecto laravel.\n${endColour}"
    exit 1
  fi
  echo -e "\n${yellowColour}[+] Proyecto de Laravel detectado\n${endColour}"
  PROJECT=$(realpath "$PROJECT")
  NAME=$(basename "$PROJECT")
  PUBLIC="$PROJECT/public"

  echo -e "${yellowColour}[+]${endColour}${grayColour} Proyecto:${endColour}${blueColour} $PROJECT${endColour}"
  echo -e "${yellowColour}[+]${endColour}${grayColour} Dominio:${endColour}${blueColour} $NAME.test${endColour}"
  echo -e "${yellowColour}[+]${endColour}${grayColour} Public:${endColour}${blueColour} $PUBLIC${endColour}\n"

  sleep 2
}

function apache(){
  echo -e "\n[+] El servidor es apache\n"
  local DOMINIO="$NAME.test"
  local ROOT_DIR="$PROJECT/public"
  local CONF_DIR=""
  local SERVICE_NAME=""
  local DEBIAN_STYLE=false


  if [ -d "/opt/lampp" ] && [ -f "/opt/lampp/lampp" ]; then

    CONF_DIR="/opt/lampp/etc/extra"
    ROOT_DIR="/opt/lampp/htdocs/$DOMINIO"
    SERVICE_NAME="xampp"
  elif command -V apache2 &>/dev/null || [ -d "/etc/apache2" ]; then
    SERVICE_NAME="apache2"
    if [ -d "/etc/apache2/sites-available" ]; then
      CONF_DIR="/etc/apache2/sites-available"
      DEBIAN_STYLE=true
    else
      CONF_DIR="/etc/apache2/conf.d"
    fi
  elif command -V httpd &>/dev/null || [ -d "/etc/httpd/" ]; then
    SERVICE_NAME="httpd"
    if [ -d "/etc/httpd/conf.d" ]; then
      CONF_DIR="/etc/httpd/conf.d"
    elif [ -d "/etc/httpd/conf" ]; then
      CONF_DIR="/etc/httpd/conf.d"
    fi
  fi
  
  if [ -z "$CONF_DIR" ]; then
    echo "Error: No se puedo localizar la carpeta de configuracion de Apache"
    echo "Asegurate de tener instaldo Apache nativo"
    exit 1
  fi

  echo "Usando configuracion en: $CONF_DIR"
  echo "Directorio raiz del sitio: $ROOT_DIR"

  sudo mkdir -p "$ROOT_DIR"
  sudo chown -R $USER:$USER "$ROOT_DIR"

  #General el virtual host
  local CONF_FILE="$CONF_DIR/$DOMINIO.conf"
  
  if [ "$CONF_DIR" == "/etc/httpd/conf/" ]; then
      CONF_FILE="/etc/httpd/conf/extra/$DOMINIO.conf"
      sudo mkdir -p "/etc/httpd/conf/extra"
      if ! grep -q "Include conf/extra/$DOMINIO.conf" /etc/httpd/conf/httpd.conf; then
        echo "Include conf/extra/$DOMINIO.conf" | sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null
      fi
  elif [ "$SERVICE_NAME" = "xampp" ]; then
    if ! grep -q "Include etc/extra/$DOMINIO.conf" /opt/lampp/etc/httpd.conf; then
      echo "Include etc/extra/$DOMINIO.conf" | sudo tee -a /opt/lampp/etc/httpd.conf > /dev/null
    fi
  fi

  sudo mkdir -p "$CONF_DIR"

  sudo tee "$CONF_FILE" > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $DOMINIO
    DocumentRoot "$ROOT_DIR"

    <Directory "$ROOT_DIR"
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
  
  #Enlaces estilo debian
  if [ "$DEBIAN_STYLE" == true ]; then
      sudo ln -sf "$CONF_FILE" "/etc/apache2/sites-enabled/"
  fi

  #Actualizar archivo hosts
  if ! grep -q "$DOMINIO" /etc/hosts; then
      echo "127.0.0.1   $DOMINIO" | sudo tee -a /etc/hosts > /dev/null
  fi
  
  #Permisos
  set_laravel_permissions

  #Reiniciar el servidor correspondiente
  echo "Reiniciando el servidor web..."
  if [ "$SERVICE_NAME" == "xampp" ]; then
      sudo /opt/lampp/lampp restartapache
  else
    sudo systemctl restart "$SERVICE_NAME"
  fi

  #Retorno limpio del nombre del dominio
  echo "Tu dominio local es: http://$DOMINIO"
}

function nginx(){
  echo -e "\n[+] El servidor es nginx\n"
}

#Ctrl + c
trap ctrl_c INT

while getopts "s:h" arg; do
  case $arg in
    s) server=$OPTARG;;
    h) helpPanel;;
  esac
done

if [ $server ]; then
  if [ "$server" == "apache" ]; then
    isLaravelProject
    checkServer
    checkOS
    apache
  elif [ "$server" == "nginx" ]; then
    checkServer
    checkOS
    isLaravelProject
    nginx
  else
    echo -e "${redColour}\n[!] Server no encontrado\n${endColour}"
  fi
fi


