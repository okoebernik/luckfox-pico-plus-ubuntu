#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS_DIR="${PROJECT_DIR}/rootfs/ubuntu-jammy"

UBUNTU_RELEASE="jammy"
UBUNTU_ARCH="armhf"
UBUNTU_MIRROR="http://ports.ubuntu.com/ubuntu-ports"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Bitte mit sudo ausführen."
    exit 1
fi

if [[ -e "${ROOTFS_DIR}/etc/os-release" ]]; then
    echo "RootFS existiert bereits: ${ROOTFS_DIR}"
    exit 1
fi

mkdir -p "${ROOTFS_DIR}"

debootstrap \
    --arch="${UBUNTU_ARCH}" \
    --foreign \
    --variant=minbase \
    "${UBUNTU_RELEASE}" \
    "${ROOTFS_DIR}" \
    "${UBUNTU_MIRROR}"

cp /usr/bin/qemu-arm-static "${ROOTFS_DIR}/usr/bin/"

chroot "${ROOTFS_DIR}" /debootstrap/debootstrap --second-stage

cp /etc/resolv.conf "${ROOTFS_DIR}/etc/resolv.conf"

cat > "${ROOTFS_DIR}/etc/hostname" <<'HOSTNAME'
luckfox
HOSTNAME

cat > "${ROOTFS_DIR}/etc/hosts" <<'HOSTS'
127.0.0.1 localhost
127.0.1.1 luckfox

::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
HOSTS

cat > "${ROOTFS_DIR}/etc/apt/sources.list" <<'SOURCES'
deb http://ports.ubuntu.com/ubuntu-ports jammy main universe multiverse restricted
deb http://ports.ubuntu.com/ubuntu-ports jammy-updates main universe multiverse restricted
deb http://ports.ubuntu.com/ubuntu-ports jammy-security main universe multiverse restricted
SOURCES

mount -t proc /proc "${ROOTFS_DIR}/proc"
mount -t sysfs /sys "${ROOTFS_DIR}/sys"
mount --bind /dev "${ROOTFS_DIR}/dev"
mount --bind /dev/pts "${ROOTFS_DIR}/dev/pts"

cleanup() {
    umount -lf "${ROOTFS_DIR}/dev/pts" 2>/dev/null || true
    umount -lf "${ROOTFS_DIR}/dev" 2>/dev/null || true
    umount -lf "${ROOTFS_DIR}/sys" 2>/dev/null || true
    umount -lf "${ROOTFS_DIR}/proc" 2>/dev/null || true
}
trap cleanup EXIT

chroot "${ROOTFS_DIR}" /bin/bash <<'CHROOT'
set -e

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y --no-install-recommends \
    systemd-sysv \
    openssh-server \
    sudo \
    ca-certificates \
    iproute2 \
    iputils-ping \
    net-tools \
    ifupdown \
    isc-dhcp-client \
    nano \
    vim-tiny \
    less \
    procps \
    kmod \
    udev \
    util-linux \
    e2fsprogs \
    curl \
    wget \
    git \
    python3 \
    python3-pip

useradd -m -s /bin/bash pico
echo 'pico:luckfox' | chpasswd
echo 'root:luckfox' | chpasswd

usermod -aG sudo pico

printf 'pico ALL=(ALL:ALL) ALL\n' > /etc/sudoers.d/pico
chmod 0440 /etc/sudoers.d/pico

mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/luckfox.conf <<'SSH'
PermitRootLogin yes
PasswordAuthentication yes
SSH

systemctl enable ssh

apt-get clean
rm -rf /var/lib/apt/lists/*
CHROOT

echo
echo "Ubuntu-RootFS wurde erstellt:"
echo "${ROOTFS_DIR}"
