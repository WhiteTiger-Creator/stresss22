# Bucketwatch object-routing rollup — deployment recovery

The Bucketwatch object-routing rollup went down after a failed deployment. The bad rollout left both the host deployment state and the rollup compiler wrong. There are three independent deliverables below, each with its own acceptance criteria; they may be done in any order.

## Deployment state

Restore the host deployment state defined in `/app/docs/deployment_runbook.md`. The runbook is authoritative for every value; the required end state is:

- the dedicated `svc-objship` system account exists with no interactive login shell;
- the operator wrapper `/usr/local/bin/ship-objects` is executable and owned by root, forwards its arguments to the live pipeline, runs as the invoking user, and exits `75` without producing output while the run lock `/var/lock/object-ship.lock` is present;
- the crashed run's stale lock is removed;
- a cron drop-in at `/etc/cron.d/object-ship` (mode `0644`) schedules the rollup under `svc-objship` using the exact job line the runbook gives;
- `/app/output` is owned `svc-objship:svc-objship` at mode `0750`;
- `/var/log/object-ship` is owned `svc-objship:svc-objship` at mode `0750`, the unrotated rollout leftover `ship.log.0` is pruned, and the live `ship.log` remains;
- a logrotate drop-in at `/etc/logrotate.d/object-ship` (mode `0644`) rotates the run log as the service account with the directives the runbook lists.

## Rollup pipeline

The rollup at `/app/workflow/export_report.py` must again turn the object telemetry at `/app/data/events.json` into its three outputs: the run summary `summary.json`, the per-bucket map `bucket_matrix.json`, and the compact JSON-lines queue `escalated.jsonl`. Acceptance is behavioural: the rollup produces correct outputs on the shipped telemetry and on an alternate event stream it has not seen, is deterministic across repeated runs, and derives every value from the telemetry and the board's rulings rather than from any precomputed or hardcoded result. The frozen pre-rollout snapshot `/app/workflow/.export_report.original` must remain unmodified; it supplies the pre-repair SHA-256 and the source tokens the repair removes.

## Audit CLI

`/app/object_audit.py` exposes two actions:

- `diagnose --dossier PATH --report PATH` reads the review dossier and writes, to the `--report` path (an output file it creates, not an input), its report of the six defects `wrong_source_field`, `risk_threshold_filter`, `recency_order`, `risk_class_normalization`, `dedupe_event` and `benign_filter`. It is stateless — every explicit call writes a complete report — and accepts only `--dossier` and `--report`; given any other flag it exits non-zero and writes no report.
- `repair --output-dir PATH` restores the rollup from the frozen snapshot, re-runs it, and writes `diagnosis.json` and `repair_audit.json` beside the three outputs, defaulting to `/app/output`.

## Where the governing rules live

Every governing value behind the rollup — severity normalization and alias handling, `object_id` deduplication tie-breaks, the dismissal-override windows and their scopes, the near and wide probe families and their opposing rounding directions, the chain correlation, the reach propagation across chains, and the sequential escalation ledger — was settled by the storage governance board and recorded only in the dossier at `/app/incident/export_dossier.md`, where a later dated ruling supersedes an earlier one. The exact schemas, key sets, digest payloads and byte-level checksum serialization are pinned by `/app/docs/report_spec.json`, with the implementation guide at `/app/docs/output_contract.md`. Two contract details are easy to overlook: `diagnosis_report.issues_found_item.evidence.required_terms_by_issue` lists, per issue id, the case-sensitive substrings each of `dossier_quote`, `pipeline_evidence` and `repair_action` must contain; and `repair_audit.processing_steps` is the exact ordered array of step names `repair_audit.json` must reproduce.
