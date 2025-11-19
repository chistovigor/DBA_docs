#!/bin/bash
# ==========================================================
# Script: update_fstab_noatime.sh
# Purpose: Safely add noatime,nodiratime to /etc/fstab entries
# ==========================================================

set -euo pipefail

# Определяем каталог, где находится сам скрипт
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Настройки путей ---
LOG_FILE="${SCRIPT_DIR}/update_fstab.log"
BACKUP_FILE="/etc/fstab.bak_$(date +%Y%m%d_%H%M)"

# --- Настройка логирования ---
exec > >(tee -a "$LOG_FILE") 2>&1
echo "=========================================================="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🛠 Starting fstab update..."
echo "Log file: $LOG_FILE"
echo "=========================================================="

# --- 1. Резервное копирование fstab ---
echo "📦 Creating backup of /etc/fstab → $BACKUP_FILE"
if sudo cp /etc/fstab "$BACKUP_FILE"; then
    echo "✅ Backup created successfully."
else
    echo "❌ Failed to create backup. Aborting."
    exit 1
fi

# --- 2. Добавляем опции noatime,nodiratime ---
echo "⚙️ Updating fstab entries..."
sudo sed -i.bak 's|\( / xfs defaults\)|\1,noatime,nodiratime|' /etc/fstab || true
sudo sed -i.bak 's|\( /opt/ssd xfs defaults\)|\1,noatime,nodiratime|' /etc/fstab || true

echo "✅ /etc/fstab updated. Current relevant entries:"
grep -E '(/ |/opt/ssd)' /etc/fstab || echo "⚠️ No entries found — check manually."

# --- 3. Проверка корректности без перемонтирования ---
echo "🔍 Validating /etc/fstab syntax (no remount yet)..."
if sudo mount -fav >/tmp/fstab_check.log 2>&1; then
    echo "✅ Syntax OK"
else
    echo "❌ Error detected in /etc/fstab:"
    cat /tmp/fstab_check.log
    echo "Restoring original backup..."
    sudo cp "$BACKUP_FILE" /etc/fstab
    echo "✅ Backup restored. Aborting update."
    exit 1
fi

# --- 4. Перемонтирование ---
echo "🔁 Applying remount..."
if sudo mount -o remount / && sudo mount -o remount /opt/ssd; then
    echo "✅ Remounted successfully."
else
    echo "⚠️ Remount failed — check system logs."
    exit 1
fi

# --- 5. Проверка применённых опций ---
echo "🔎 Verifying applied options..."
if mount | grep -E '(/ |/opt/ssd)' | grep -qE 'noatime|nodiratime'; then
    echo "✅ noatime/nodiratime options are active."
else
    echo "⚠️ Options not detected — verify manually:"
    mount | grep -E '(/ |/opt/ssd)'
fi

echo "=========================================================="
echo "[$(date '+%Y-%m-%d %H:%M')] 🎉 fstab update completed successfully."
echo "Backup: $BACKUP_FILE"
echo "Log saved to: $LOG_FILE"
echo "=========================================================="
