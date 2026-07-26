#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Restore the deployment state per /app/docs/deployment_runbook.md ---
# Dedicated service account with no interactive shell.
if ! getent passwd svc-objship >/dev/null; then
  useradd --system --shell /usr/sbin/nologin svc-objship
fi

# Operator wrapper: executable, targets the live pipeline, honors the run lock.
cat > /usr/local/bin/ship-objects <<'EOF'
#!/bin/sh
LOCK=/var/lock/object-ship.lock
if [ -e "$LOCK" ]; then
  echo "object ship blocked by existing lock: $LOCK" >&2
  exit 75
fi
exec python3 /app/workflow/export_report.py "$@"
EOF
chmod 0755 /usr/local/bin/ship-objects

# Clear the stale lock left by the crashed rollout.
rm -f /var/lock/object-ship.lock

# Reinstate the schedule under the service account.
printf '*/5 * * * * svc-objship /usr/local/bin/ship-objects --input /app/data/events.json --output-dir /app/output\n' \
  > /etc/cron.d/object-ship
chmod 0644 /etc/cron.d/object-ship

# Output directory ownership and mode per runbook.
mkdir -p /app/output
chown svc-objship:svc-objship /app/output
chmod 0750 /app/output

# Log directory: prune the rollout leftover, hand the directory to the service account,
# and drop the world-writable mode.
mkdir -p /var/log/object-ship
rm -f /var/log/object-ship/ship.log.0
chown -R svc-objship:svc-objship /var/log/object-ship
chmod 0750 /var/log/object-ship

# Rotation drop-in: su/create keep rotated files owned by svc-objship.
cat > /etc/logrotate.d/object-ship <<'ROTEOF'
/var/log/object-ship/*.log {
    daily
    rotate 14
    compress
    missingok
    notifempty
    su svc-objship svc-objship
    create 0640 svc-objship svc-objship
}
ROTEOF
chmod 0644 /etc/logrotate.d/object-ship

cp "${SCRIPT_DIR}/object_audit.py" /app/object_audit.py
chmod +x /app/object_audit.py
mkdir -p /app/output /app/audit

# Ensure frozen broken snapshot exists for pre-repair audit reads.
if [ ! -f /app/workflow/.export_report.original ]; then
  cp /app/workflow/export_report.py /app/workflow/.export_report.original
  chmod a-w /app/workflow/.export_report.original
fi

python3 /app/object_audit.py diagnose \
  --dossier /app/incident/export_dossier.md \
  --report /app/output/diagnosis.json

python3 /app/object_audit.py repair --output-dir /app/output

# Compatibility copy for harnesses that read /app/audit.
cp /app/output/diagnosis.json /app/audit/diagnosis.json
cp /app/output/repair_audit.json /app/audit/repair_audit.json
