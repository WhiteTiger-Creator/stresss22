# Rubric — Bucketwatch Object-Routing Rollup Recovery

## Positive criteria

Agent provisions the svc-objship service account with no interactive login shell, ±2
Agent installs the operator wrapper /usr/local/bin/ship-objects executable at mode 0755, targeting the live pipeline and not the missing legacy path, ±2
Agent makes the wrapper exit status 75 without output while the run lock /var/lock/object-ship.lock is present, and clears the stale rollout lock during recovery, ±2
Agent reinstates the cron drop-in /etc/cron.d/object-ship with the exact runbook job line running under the service account, ±2
Agent installs the logrotate drop-in for /var/log/object-ship so rotation actually runs and keeps rotated files owned by the service account, ±2
Agent repairs /app/workflow/export_report.py so summary.json, bucket_matrix.json and escalated.jsonl match the report_spec.json schemas, key sets, identifier payloads and checksum encodings exactly, ±5
Agent's object_audit.py diagnose reports the six governed defects statelessly, accepts only its two flags, and exits non-zero on any other, ±3
Agent applies the later-dated dossier rulings where entries disagree, so normalization, dedupe, override windows, the near and wide probes, chain correlation, reach and the escalation ledger match the signed-off behaviour, ±3
Agent produces correct output on an alternate event stream it has not seen and identical output across repeated runs, ±3

## Negative criteria

Agent leaves /app/output or /var/log/object-ship world-writable after recovery, -2
Agent hardcodes, copies or otherwise derives any output value from a precomputed or expected-output file rather than from the inputs and rulings, -3
Agent modifies the frozen reference snapshot /app/workflow/.export_report.original, -2
Agent's wrapper drops privileges itself or runs the pipeline while the lock is held, -2
Agent leaves the crashed run's stale lock or the unrotated log leftover in place, -1
