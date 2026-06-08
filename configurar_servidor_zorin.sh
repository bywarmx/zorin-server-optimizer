#!/bin/bash

# Colores para la terminal
VERDE="\e[0;32m"
ROJO="\e[0;31m"
AZUL="\e[0;34m"
AMARILLO="\e[0;33m"
RESET="\e[0m"

# Validar si se ejecuta como root (requerido para modificar systemd)
if [ "$EUID" -ne 0 ]; then
  echo -e "${ROJO}Error: Este script debe ser ejecutado con privilegios de root (usa sudo).${RESET}"
  echo -e "Ejemplo: sudo $0"
  exit 1
fi

# Detectar el usuario real que invocó sudo
USUARIO_REAL=${SUDO_USER:-$(logname 2>/dev/null)}
if [ -z "$USUARIO_REAL" ] || [ "$USUARIO_REAL" = "root" ]; then
  USUARIO_REAL="bywarrior"
fi

mostrar_menu() {
  echo -e "${AZUL}=====================================================${RESET}"
  echo -e "${VERDE}    Optimización de Zorin OS 18 para Servidor Web    ${RESET}"
  echo -e "${AZUL}=====================================================${RESET}"
  echo -e "Este script configurará tu miniPC para optimizar el consumo:"
  echo -e "  1. Desactiva el entorno gráfico de escritorio."
  echo -e "  2. Configura el inicio de sesión automático (autologin)"
  echo -e "     para el usuario '${AMARILLO}$USUARIO_REAL${RESET}' en modo consola."
  echo -e "  3. Permite revertir estos cambios fácilmente."
  echo -e "-----------------------------------------------------"
  echo -e "Elige una opción:"
  echo -e "  [1] Aplicar optimización (Modo Servidor / Sin entorno gráfico)"
  echo -e "  [2] Revertir optimización (Modo Escritorio / Con entorno gráfico)"
  echo -e "  [3] Salir"
  echo -e "-----------------------------------------------------"
}

aplicar_optimizacion() {
  echo -e "\n${AZUL}[*] Iniciando optimización para modo servidor...${RESET}"

  # 1. Configurar autologin en TTY1
  echo -e "${AZUL}[*] Configurando inicio automático para el usuario: ${AMARILLO}$USUARIO_REAL${RESET}..."
  DIR_OVERRIDE="/etc/systemd/system/getty@tty1.service.d"
  mkdir -p "$DIR_OVERRIDE"
  
  cat <<EOF > "$DIR_OVERRIDE/override.conf"
[Service]
ExecStart=
ExecStart=-/sbin/agetty --noclear --autologin $USUARIO_REAL %I \$TERM
EOF

  if [ $? -eq 0 ]; then
    echo -e "${VERDE}[✓] Regla de autologin creada con éxito en $DIR_OVERRIDE/override.conf.${RESET}"
  else
    echo -e "${ROJO}[✗] Error al crear la regla de autologin.${RESET}"
    exit 1
  fi

  # 2. Recargar systemd
  echo -e "${AZUL}[*] Recargando el gestor de servicios systemd...${RESET}"
  systemctl daemon-reload

  # 3. Cambiar target por defecto a multi-user (modo consola)
  echo -e "${AZUL}[*] Configurando el inicio por defecto en modo consola...${RESET}"
  systemctl set-default multi-user.target

  if [ $? -eq 0 ]; then
    echo -e "${VERDE}[✓] Sistema configurado para arrancar en modo consola.${RESET}"
  else
    echo -e "${ROJO}[✗] Error al cambiar el target de arranque.${RESET}"
    exit 1
  fi

  echo -e "\n${VERDE}=====================================================${RESET}"
  echo -e "${VERDE}¡Optimización completada con éxito!${RESET}"
  echo -e "Al reiniciar, tu miniPC entrará directo en modo consola"
  echo -e "con el usuario '${AMARILLO}$USUARIO_REAL${RESET}' ya autenticado."
  echo -e "Todos tus servidores web y servicios seguirán funcionando."
  echo -e "====================================================="
  read -p "¿Deseas reiniciar el sistema ahora? (s/n): " opcion_reiniciar
  if [[ "$opcion_reiniciar" =~ ^[Ss]$ ]]; then
    echo -e "${AZUL}[*] Reiniciando el equipo...${RESET}"
    reboot
  fi
}

revertir_optimizacion() {
  echo -e "\n${AZUL}[*] Revirtiendo optimizaciones... Volviendo a modo Escritorio...${RESET}"

  # 1. Eliminar regla de autologin de consola
  DIR_OVERRIDE="/etc/systemd/system/getty@tty1.service.d"
  if [ -d "$DIR_OVERRIDE" ]; then
    echo -e "${AZUL}[*] Eliminando regla de autologin en consola...${RESET}"
    rm -rf "$DIR_OVERRIDE"
    echo -e "${VERDE}[✓] Regla de autologin eliminada.${RESET}"
  else
    echo -e "${AMARILLO}[!] No se encontró regla de autologin previa.${RESET}"
  fi

  # 2. Recargar systemd
  echo -e "${AZUL}[*] Recargando systemd...${RESET}"
  systemctl daemon-reload

  # 3. Cambiar target por defecto a graphical (modo escritorio)
  echo -e "${AZUL}[*] Configurando inicio por defecto con entorno gráfico...${RESET}"
  systemctl set-default graphical.target

  if [ $? -eq 0 ]; then
    echo -e "${VERDE}[✓] Zorin OS configurado para iniciar en modo gráfico.${RESET}"
  else
    echo -e "${ROJO}[✗] Error al restaurar el modo gráfico.${RESET}"
    exit 1
  fi

  echo -e "\n${VERDE}=====================================================${RESET}"
  echo -e "${VERDE}¡Restauración completada con éxito!${RESET}"
  echo -e "Al reiniciar, tu miniPC volverá a cargar el escritorio de Zorin OS."
  echo -e "====================================================="
  read -p "¿Deseas reiniciar el sistema ahora? (s/n): " opcion_reiniciar
  if [[ "$opcion_reiniciar" =~ ^[Ss]$ ]]; then
    echo -e "${AZUL}[*] Reiniciando el equipo...${RESET}"
    reboot
  fi
}

# Flujo principal
mostrar_menu
read -p "Elige una opción [1-3]: " opcion

case $opcion in
  1)
    aplicar_optimizacion
    ;;
  2)
    revertir_optimizacion
    ;;
  3)
    echo -e "${AMARILLO}Saliendo sin aplicar cambios.${RESET}"
    exit 0
    ;;
  *)
    echo -e "${ROJO}Opción inválida.${RESET}"
    exit 1
    ;;
esac
