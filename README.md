# Zorin OS 18 - Server Optimizer 🚀

Este script en Bash permite optimizar y transformar tu instalación de **Zorin OS 18** (o distribuciones basadas en Ubuntu 24.04/Debian) en un servidor web de bajo consumo de recursos. Desactiva el entorno gráfico de escritorio y configura el inicio de sesión automático (autologin) en modo texto (consola).

El proceso es **100% reversible** en cualquier momento desde el propio menú del script.

---

## ⚡ ¿Qué hace este script?

1. **Desactiva el Entorno Gráfico (GUI):** Configura `systemd` para arrancar por defecto en modo consola (`multi-user.target`), liberando inmediatamente entre **1.2 GB y 2 GB de memoria RAM** y reduciendo la carga de CPU, lo que disminuye el consumo eléctrico y la temperatura del procesador.
2. **Configura Autologin en Consola:** Genera una regla específica para `getty@tty1` que inicia sesión de forma automática con tu usuario en la consola de texto tras encender la máquina.
3. **Mantiene tus Servicios Activos:** Todos tus servidores web (Apache, Nginx), bases de datos (MySQL, PostgreSQL), Docker, túneles (Cloudflare, Tailscale) y terminales web (`ttyd`) siguen funcionando exactamente igual en segundo plano.
4. **Reversión en un clic:** Permite volver a restaurar el entorno gráfico original de Zorin OS y remover la regla de autologin de consola de manera limpia.

---

## 📋 Requisitos

* Sistema operativo Zorin OS 18 (o compatible basado en Ubuntu/Debian).
* Un usuario del sistema con permisos de administrador (`sudo`).

---

## 🚀 Instalación y Ejecución

Puedes utilizar el script directamente clonando este repositorio en tu máquina:

### Opción 1: Ejecutar de manera local (Clonando el repositorio)

1. Abre una terminal y clona este repositorio:
   ```bash
   git clone https://github.com/bywarmx/zorin-server-optimizer.git
   ```

2. Entra al directorio del repositorio:
   ```bash
   cd zorin-server-optimizer
   ```

3. Dale permisos de ejecución al script (opcional, ya debería tenerlos):
   ```bash
   chmod +x configurar_servidor_zorin.sh
   ```

4. Ejecuta el script con privilegios de superusuario (`sudo`):
   ```bash
   sudo ./configurar_servidor_zorin.sh
   ```

### Opción 2: Ejecución ultra rápida en un solo comando (Directo desde internet)

Si no deseas clonar el repositorio y quieres ejecutar el script de forma directa, puedes hacerlo con el siguiente comando:

```bash
curl -sSL https://raw.githubusercontent.com/bywarmx/zorin-server-optimizer/main/configurar_servidor_zorin.sh | sudo bash
```

---

## 🛠️ Menú de Opciones del Script

Al ejecutar el script verás una interfaz interactiva en la terminal con las siguientes opciones:

* **`[1] Aplicar optimización (Modo Servidor / Sin entorno gráfico)`**
  Aplica los cambios, configura el autologin en TTY1 para tu usuario y desactiva la interfaz gráfica para el próximo reinicio. Te preguntará si deseas reiniciar el equipo en ese momento.

* **`[2] Revertir optimización (Modo Escritorio / Con entorno gráfico)`**
  Revierte todo a la normalidad: elimina la regla de autologin de texto y restaura el entorno gráfico de Zorin OS.

* **`[3] Salir`**
  Cierra el script sin aplicar ninguna modificación al sistema.

---

## 🔒 Consideraciones de Seguridad

* **Acceso Físico:** Al activar el inicio de sesión automático (autologin) en consola, cualquier persona que conecte un teclado y un monitor físico a tu miniPC tendrá acceso directo a tu usuario sin pedirle contraseña. Utilízalo en entornos domésticos o de desarrollo controlado.
* **Acceso Remoto:** Esta configuración no afecta la seguridad del acceso por red (SSH o servicios web), los cuales seguirán solicitando sus credenciales de seguridad habituales.
