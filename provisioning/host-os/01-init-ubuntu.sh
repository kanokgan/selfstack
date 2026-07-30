#!/usr/bin/env bash
set -euo pipefail

echo "=== 1. Updating system packages ==="
sudo apt-get update && sudo apt-get upgrade -y

echo "=== 2. Installing essential utilities ==="
sudo apt-get install -y \
  curl \
  wget \
  git \
  open-iscsi \
  nfs-common \
  qemu-guest-agent

echo "=== 3. Disabling SWAP ==="
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "=== 4. Enabling required kernel modules ==="
cat <<EOF | sudo tee /etc/modules-load.d/k3s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

echo "=== 5. Setting up sysctl settings for k3s networking ==="
cat <<EOF | sudo tee /etc/sysctl.d/99-k3s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

echo "=== Host initialization complete! Please reboot the server. ==="