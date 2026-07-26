# Object-Routing Compile — Deployment Runbook

Operational deployment contract for the object-routing rollup on responder hosts. This document defines the required deployment state; the rollup's output contract lives in `report_spec.json` and its behavioural record in the review dossier.

## Service account

The *scheduled* rollup runs under the dedicated system account `svc-objship` — that identity is selected by the cron drop-in below (the user field of the cron line), not by the wrapper. The account has no interactive login shell (`/usr/sbin/nologin`).

## Wrapper

Operations invokes the rollup only through `/usr/local/bin/ship-objects`:

- mode `0755`, owned by root
- forwards all arguments to `python3 /app/workflow/export_report.py`
- runs the rollup **as the invoking user**: the wrapper must not switch user, `su`, `sudo`, `setpriv`, `setuid`, or otherwise change privileges — selecting the `svc-objship` identity is the cron drop-in's job, not the wrapper's
- concurrency guard: when the lock file `/var/lock/object-ship.lock` exists, the wrapper must exit with status `75` (EX_TEMPFAIL) without invoking the rollup or writing any output

Stale locks left behind by crashed runs are removed during recovery, not worked around.

## Schedule

The rollup is scheduled through a cron drop-in at `/etc/cron.d/object-ship`, mode `0644`, containing exactly this job line:

```
*/5 * * * * svc-objship /usr/local/bin/ship-objects --input /app/data/events.json --output-dir /app/output
```

## Output directory

`/app/output` is owned `svc-objship:svc-objship` with mode `0750`. World-writable output directories are a rollout defect and must not survive recovery.

## Log directory

The rollup writes its run log under `/var/log/object-ship`. The directory is owned `svc-objship:svc-objship` with mode `0750`; a world-writable log directory is a rollout defect and must not survive recovery. The crashed rollout also left an unrotated leftover at `/var/log/object-ship/ship.log.0` — recovery prunes rollout leftovers rather than leaving them for the next rotation. The live `ship.log` itself stays in place.

## Log rotation

Rotation is configured by a drop-in at `/etc/logrotate.d/object-ship`, mode `0644`, owned root, covering `/var/log/object-ship/*.log` and declaring exactly these directives:

```
/var/log/object-ship/*.log {
    daily
    rotate 14
    compress
    missingok
    notifempty
    su svc-objship svc-objship
    create 0640 svc-objship svc-objship
}
```

Rotation runs as the service account, not as root: the `su` and `create` lines are what keep rotated files owned by `svc-objship`.
