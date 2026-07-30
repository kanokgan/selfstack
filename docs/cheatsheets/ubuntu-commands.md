# Ubuntu Server Essential Commands Cheatsheet

Quick reference guide for daily Ubuntu Linux administration, process management, system updates, and power controls.

---

## 1. System Updates & Maintenance

| Action | Command |
| :--- | :--- |
| **List upgradable packages** | `apt list --upgradable` |
| **Update package list & upgrade all software** | `sudo apt update && sudo apt upgrade -y` |
| **Clean up unused packages/dependencies** | `sudo apt autoremove -y` |

---

## 2. Power Management

| Action | Command |
| :--- | :--- |
| **Reboot server immediately** | `sudo reboot` |
| **Shutdown server immediately** | `sudo shutdown -h now` *(or `sudo poweroff`)* |
| **Schedule shutdown in 10 minutes** | `sudo shutdown +10 "Shutting down for maintenance"` |
| **Cancel scheduled shutdown** | `sudo shutdown -c` |

---

## 3. Process Monitoring & Management

| Action | Command |
| :--- | :--- |
| **Interactive process monitor** | `htop` *(Press `q` to quit)* |
| **List all running processes** | `ps aux` |
| **Find specific process by name** | `ps aux \| grep -i <process_name>` |
| **Gracefully terminate process by ID (PID)** | `kill <PID>` |
| **Force kill process by ID (PID)** | `sudo kill -9 <PID>` |
| **Gracefully terminate processes by name** | `sudo pkill <process_name>` |
| **Force kill processes by name** | `sudo pkill -9 <process_name>` |

---

## 4. System Resources & Storage

| Action | Command |
| :--- | :--- |
| **Check RAM & Swap usage** | `free -h` |
| **Check overall disk usage** | `df -h` |
| **Check specific disk partition usage** | `df -h /` |
| **Check size of specific directory** | `sudo du -sh /var/log/*` |

---

## 5. System Services (`systemctl`)

| Action | Command |
| :--- | :--- |
| **Check service status** | `sudo systemctl status <service_name>` |
| **Start / Stop / Restart service** | `sudo systemctl restart <service_name>` |
| **Enable service on boot** | `sudo systemctl enable <service_name>` |
| **View system logs for service** | `sudo journalctl -u <service_name> -f` |