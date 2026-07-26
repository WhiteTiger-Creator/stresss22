FROM public.ecr.aws/docker/library/python:3.13-slim-bookworm@sha256:01f42367a0a94ad4bc17111776fd66e3500c1d87c15bbd6055b7371d39c124fb

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        tmux \
        asciinema \
    && rm -rf /var/lib/apt/lists/*

# Hash-locked verifier dependencies: --require-hashes verifies each downloaded
# artifact against the pinned SHA-256 in the lock (the lock is the complete
# dependency closure), so a tampered or substituted package fails the build.
COPY requirements.lock /tmp/requirements.lock
RUN python3 -m pip install --no-cache-dir --require-hashes \
        -r /tmp/requirements.lock

WORKDIR /app

COPY app/ /app/
RUN cp /app/workflow/export_report.py /app/workflow/.export_report.original \
    && chmod a-w /app/workflow/.export_report.original

# Operational wiring left behind by the failed object-routing rollout: a non-executable
# wrapper pointing at a path that no longer exists, a stale run lock, no schedule entry,
# and a world-writable output directory.
RUN printf '#!/bin/sh\nexec python3 /app/workflow/export_report.py.legacy "$@"\n' > /usr/local/bin/ship-objects \
    && chmod 0644 /usr/local/bin/ship-objects \
    && mkdir -p /var/lock \
    && printf '4711\n' > /var/lock/object-ship.lock \
    && rm -f /etc/cron.d/object-ship \
    && mkdir -p /app/output \
    && chmod 0777 /app/output

# Log wiring the rollout also left wrong: the run-log directory is world-writable and still
# root-owned, its rotation drop-in was never installed, and an unrotated leftover from the
# crashed run is still sitting in the directory.
RUN mkdir -p /var/log/object-ship \
    && chmod 0777 /var/log/object-ship \
    && printf 'rollout 4711 aborted mid-run\n' > /var/log/object-ship/ship.log.0 \
    && printf '' > /var/log/object-ship/ship.log \
    && rm -f /etc/logrotate.d/object-ship
