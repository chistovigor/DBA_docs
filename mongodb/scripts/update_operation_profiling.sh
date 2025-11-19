#!/usr/bin/env bash
#
# update_operation_profiling.sh
#
# Ensures the "operationProfiling" section exists and is configured correctly.
# Usage:
#   sudo bash update_operation_profiling.sh <SLOW_OP_THRESHOLD>
#

set -euo pipefail

CONFIG_FILE="/etc/mongod.conf"

# --- Argument validation ---
if [[ $# -lt 1 ]]; then
  echo "❌ Error: missing required argument <SLOW_OP_THRESHOLD>."
  echo "Usage: sudo bash $0 <SLOW_OP_THRESHOLD>"
  echo "Example: sudo bash $0 10"
  exit 1
fi

SLOW_OP_THRESHOLD="$1"

# Validate integer
if ! [[ "$SLOW_OP_THRESHOLD" =~ ^[0-9]+$ ]]; then
  echo "❌ Error: SLOW_OP_THRESHOLD must be an integer."
  exit 1
fi

# Ensure config exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ MongoDB config not found: $CONFIG_FILE"
  exit 1
fi

timestamp=$(date '+%Y%m%d_%H%M')
backup_file="${CONFIG_FILE}.${timestamp}.bak"
cp -a "$CONFIG_FILE" "$backup_file"
echo "✅ Backup created: $backup_file"

# --- Check for operationProfiling section ---
if ! grep -qE '^\s*operationProfiling:' "$CONFIG_FILE"; then
  echo "⚙️  Section 'operationProfiling' not found — appending at the end."

  # Remove trailing blank lines
  sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CONFIG_FILE"

  # Add exactly one blank line, then section
  {
    echo ""
    echo "operationProfiling:"
    echo "  slowOpThresholdMs: ${SLOW_OP_THRESHOLD}"
  } >> "$CONFIG_FILE"

  echo "✅ Section added (slowOpThresholdMs: ${SLOW_OP_THRESHOLD})."
  exit 0
fi

# --- Extract existing section ---
profiling_block=$(awk '
  /^\s*operationProfiling:/ {inblock=1; next}
  inblock && /^\S/ {inblock=0}
  inblock
' "$CONFIG_FILE")

# If block contains other parameters besides slowOpThresholdMs → report only
if echo "$profiling_block" | grep -qvE '^\s*slowOpThresholdMs:'; then
  echo "⚠️  Found additional parameters in operationProfiling — no changes made."
  echo "🔎  Existing block content:"
  echo "$profiling_block"
  exit 0
fi

# Get current value
current_value=$(echo "$profiling_block" | grep -E 'slowOpThresholdMs:' | awk -F: '{print $2}' | tr -d '[:space:]')

if [[ "$current_value" == "$SLOW_OP_THRESHOLD" ]]; then
  echo "ℹ️  slowOpThresholdMs is already $SLOW_OP_THRESHOLD — nothing to do."
  exit 0
fi

# --- Update existing value ---
echo "🔧 Updating slowOpThresholdMs: ${current_value} → ${SLOW_OP_THRESHOLD}"
sed -i "/^\s*operationProfiling:/,/^[^[:space:]]/ s/^\(\s*slowOpThresholdMs:\).*/\1 ${SLOW_OP_THRESHOLD}/" "$CONFIG_FILE"
echo "✅ slowOpThresholdMs updated to ${SLOW_OP_THRESHOLD}."
