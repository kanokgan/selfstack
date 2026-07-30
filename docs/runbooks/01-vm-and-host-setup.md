---
id: RUN-001
title: VM & Host OS Initialization
version: 1.1.0
status: Active
author: kanokgan
created_at: 2026-07-30
updated_at: 2026-07-30
target_environment: Dev (UTM VM on Apple Silicon Mac) / Bare-Metal
related_scripts:
  - provisioning/host-os/01-init-ubuntu.sh
---

# RUN-001: VM & Host OS Initialization

## 1. Document History

| Version | Date       | Author   | Description of Changes |
| :---    | :---       | :---     | :---                   |
| 1.0.0   | 2026-07-30 | kanokgan | Initial runbook draft |
| 1.1.0   | 2026-07-30 | kanokgan | Added step-by-step VM creation, Ubuntu ISO setup, manual nano script setup |

---

## 2. Overview & Purpose
This runbook defines the complete operational procedure for provisioning an Ubuntu Server virtual machine using **UTM on Apple Silicon (M-series Mac)**, configuring initial network/SSH access, creating the host initialization script, and preparing the host for k3s cluster installation.

---

## 3. Target Environment Details
* **Hypervisor:** UTM (macOS Apple Silicon Virtualization Framework)
* **Hostname:** `selfstack-vm`
* **Primary User:** `kanokgan`
* **Target IP:** `192.168.0.204` (Assigned via Router Bridged Network / DHCP)
* **OS Distribution:** Ubuntu Server 24.04 LTS (ARM64 / aarch64)

---

## 4. Prerequisites
Before starting, ensure you have on your Mac:
1. **UTM Virtual Machine Software** installed (Download from [mac.utm.app](https://mac.utm.app/)).
2. **Ubuntu Server ARM64 ISO** image downloaded (`ubuntu-24.04-live-server-arm64.iso`).
3. Mac Terminal access with an available SSH key (`~/.ssh/id_ed25519.pub` or `id_rsa.pub`).

---

## 5. Execution Steps

### Step 5.1: Create the Virtual Machine in UTM
1. Open **UTM** on your Mac and click **Create a New Machine**.
2. Select **Virtualize** -> **Linux**.
3. Under **Boot ISO Image**, click **Browse** and select your downloaded `ubuntu-24.04-live-server-arm64.iso`.
4. Configure hardware resources:
   * **RAM:** `4096 MB` (4 GB) or `8192 MB` (8 GB)
   * **CPU Cores:** `2` or `4` cores
   * **Storage Size:** `32 GB` or `50 GB`
5. Configure Networking:
   * Select **Bridged Network** (Connects VM directly to your home router so it gets its own IP address on `192.168.0.x`).
6. Name the VM **`selfstack-vm`** and click **Save**.

---

### Step 5.2: Install Ubuntu Server OS
1. Start the VM in UTM and select **Try or Install Ubuntu Server**.
2. Complete the installer prompts:
   * **Language / Keyboard:** Default / English.
   * **Type of Install:** Ubuntu Server (default).
   * **Networking:** Observe the dynamic IP assigned by your router (e.g. `192.168.0.204`).
   * **Storage:** Select **Use an entire disk**.
   * **Profile Setup:**
     * **Your name:** `kanokgan`
     * **Server name:** `selfstack-vm`
     * **Username:** `kanokgan`
     * **Password:** *(Set your secure password)*
   * **SSH Setup:** Check **Install OpenSSH server** (Required).
   * **Featured Snaps:** Leave all unchecked -> Click **Done**.
3. Once installation completes, select **Reboot Now** and clear the ISO image when prompted.

---

### Step 5.3: Identify IP Address & Connect via Mac Terminal
1. Once the VM boots to the console prompt, confirm the assigned IP address shown on screen (e.g. `192.168.0.204`).
2. Open **Terminal** on your Mac and SSH into the VM:
   ```bash
   ssh kanokgan@192.168.0.204
   ```
3. *(Optional)* Copy your Mac SSH public key to skip entering passwords in future sessions:
   ```bash
   ssh-copy-id kanokgan@192.168.0.204
   ```

---

### Step 5.4: Create the Host Initialization Script
On the VM (via SSH), create the directory structure and write the initialization script:

1. Create directory structure:
   ```bash
   mkdir -p provisioning/host-os
   ```

2. Open `nano` text editor to create the script file:
   ```bash
   nano provisioning/host-os/01-init-ubuntu.sh
   ```

3. Paste the following script contents into `nano`:
   ```bash
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
   ```

4. Save and exit `nano`:
   * Press `Ctrl + O`, then press `Enter` to confirm file save.
   * Press `Ctrl + X` to exit editor.

---

### Step 5.5: Execute Script & Reboot Host
1. Grant execute permissions to the script:
   ```bash
   chmod +x provisioning/host-os/01-init-ubuntu.sh
   ```

2. Execute the initialization script:
   ```bash
   ./provisioning/host-os/01-init-ubuntu.sh
   ```

3. Reboot the VM to apply kernel modules and sysctl network parameters:
   ```bash
   sudo reboot
   ```

---

## 6. Verification Checklist
After the host reboots, reconnect via SSH (`ssh kanokgan@192.168.0.204`) and verify:

- [ ] **System reachable via SSH:** `ssh kanokgan@192.168.0.204`
- [ ] **Swap disabled:** Run `free -m` (Swap total line must show `0`).
- [ ] **Kernel modules loaded:** Run `lsmod | grep -E 'overlay|br_netfilter'`.
- [ ] **Network IP forwarding active:** Run `sysctl net.ipv4.ip_forward` (Must return `1`).
- [ ] **Storage services active:** Run `systemctl is-active open-iscsi`.

---

## 7. Rollback / Troubleshooting
* **Cannot connect via SSH:** Ensure VM network setting in UTM is set to **Bridged Network** and check `ip addr` in the UTM console window.
* **Swap re-enabled:** Re-run `sudo swapoff -a` and inspect `/etc/fstab` to ensure swap line is commented out.
* **Kernel modules missing:** Run `sudo modprobe overlay` and `sudo modprobe br_netfilter` manually.
```

---
