# Bucketwatch Object Storage Containment Runbook

Required hardened state for any object-storage control plane touched by the Bucketwatch intrusion. The sync
automation provisioned itself with persistence and escalation paths that must be removed while
the storage control plane is contained; the object triage rollup is not restored until the host matches this
runbook.

## SSH persistence

The automation appended its own deploy key to root's `authorized_keys`, identified by the key
comment `objsync-automation`. Revoke it: no entry carrying that comment may remain in
`/root/.ssh/authorized_keys`. The file also carries the ops on-call bastion key (comment
`ops-oncall@bastion`). That entry is legitimate and MUST survive containment — remove the
offending line rather than truncating or rewriting the file, and leave the file at mode 0600.
Locking responders out of the storage control plane is a containment failure, not a containment success.

## Privilege escalation

The automation installed a temporary sudoers drop-in at `/etc/sudoers.d/objsync` granting
`svc-objsync` passwordless root. Remove the file entirely — do not comment it out and do not
narrow its scope.

## Object key exposure

The object-signing key at `/app/secrets/object_signing.key` was written world-readable. The key
is still valid and the storage control plane still needs it in place: keep the file, owned `root:root`, mode
`0600`.
