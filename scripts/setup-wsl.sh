#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update

sudo apt-get install -y \
  git \
  ssh \
  make \
  gcc \
  gcc-multilib \
  g++-multilib \
  module-assistant \
  expect \
  g++ \
  gawk \
  texinfo \
  libssl-dev \
  bison \
  flex \
  fakeroot \
  cmake \
  unzip \
  gperf \
  autoconf \
  debootstrap \
  device-tree-compiler \
  e2fsprogs \
  libncurses5-dev \
  pkg-config \
  bc \
  parted \
  python-is-python3 \
  qemu-user-static \
  passwd \
  openssl \
  openssh-server \
  openssh-client \
  curl \
  wget \
  vim \
  file \
  cpio \
  rsync

echo "Build-Abhängigkeiten wurden installiert."
