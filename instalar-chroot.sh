#!/bin/bash
# Instalador de Ubuntu Chroot para Termux (Seguro)

echo -e "\e[1;34m[+] Preparando instalación de Ubuntu Chroot Nativo...\e[0m"

# Directorios
CHROOT_DIR="$HOME/ubuntu-chroot"
START_SCRIPT="$HOME/start-ubuntu.sh"

# Instalar dependencias si faltan
pkg install -y wget tar tsu proot

if [ -d "$CHROOT_DIR" ]; then
    echo -e "\e[1;33m[!] El directorio $CHROOT_DIR ya existe.\e[0m"
    echo "Si quieres reinstalar, borra la carpeta con: s rm -rf $CHROOT_DIR"
    exit 1
fi

mkdir -p "$CHROOT_DIR"
cd "$CHROOT_DIR"

echo -e "\e[1;34m[+] Descargando Ubuntu 24.04 Base (ARM64)...\e[0m"
wget https://cdimage.ubuntu.com/ubuntu-base/releases/24.04/release/ubuntu-base-24.04-base-arm64.tar.gz -O ubuntu.tar.gz

echo -e "\e[1;34m[+] Extrayendo sistema base (requiere Root)...\e[0m"
# Extraemos usando sudo para conservar permisos root en el rootfs
sudo tar -xpf ubuntu.tar.gz --numeric-owner
sudo rm ubuntu.tar.gz

echo -e "\e[1;34m[+] Configurando red (DNS)...\e[0m"
sudo bash -c "echo 'nameserver 8.8.8.8' > etc/resolv.conf"
sudo bash -c "echo 'nameserver 1.1.1.1' >> etc/resolv.conf"

echo -e "\e[1;34m[+] Creando script de arranque seguro...\e[0m"
cat << 'EOF' > "$START_SCRIPT"
#!/bin/bash
# Script para iniciar Ubuntu en modo Chroot

CHROOT_DIR="$HOME/ubuntu-chroot"

echo "Montando sistemas de archivos vitales..."
sudo mount --bind /dev "$CHROOT_DIR/dev"
sudo mount --bind /sys "$CHROOT_DIR/sys"
sudo mount --bind /proc "$CHROOT_DIR/proc"
sudo mount --bind /dev/pts "$CHROOT_DIR/dev/pts"
# Opcional: Compartir almacenamiento interno de Android
# sudo mount --bind /sdcard "$CHROOT_DIR/mnt/sdcard"

echo "Entrando al entorno Nativo Ubuntu (Chroot)..."
sudo chroot "$CHROOT_DIR" /bin/bash -c "su - root"

echo "Desmontando sistemas de archivos de forma segura..."
sudo umount "$CHROOT_DIR/dev/pts"
sudo umount "$CHROOT_DIR/proc"
sudo umount "$CHROOT_DIR/sys"
sudo umount "$CHROOT_DIR/dev"
# sudo umount "$CHROOT_DIR/mnt/sdcard"
echo "Chroot cerrado correctamente."
EOF

chmod +x "$START_SCRIPT"

echo -e "\e[1;32m[+] ¡Instalación completada!\e[0m"
echo -e "\e[1;37mPara entrar a tu nuevo Ubuntu Nativo, simplemente ejecuta:\e[0m"
echo -e "\e[1;32m./start-ubuntu.sh\e[0m"
