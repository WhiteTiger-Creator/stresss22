# Bucketwatch Object-Routing Review Dossier
Corvus Storage Operations — object-routing review archive (2026-Q1 through 2026-Q2).

## Executive Summary
Attestation rollup export has been unstable since early 2026. Early triage blamed dashboard cache lag and suggested CSV fallback — those notes are archived below and may contradict later findings. For acceptance behavior, cross-check analyst notes embedded in console-window objects against bundled events.json — early triage sections above are not authoritative.

How the export is *meant* to behave — normalization, dedupe and its tie-breaks, override windows and matching, pressure scoring, chain correlation and the directed reach graph — was settled incrementally during the Bucketwatch review, and those decisions live as #OBJ-ticketed notes scattered through the shift log below, not in any single summary. The February triage proposals were revisited in 2026-05 and several were reversed; where a proposal and a later decision disagree, the later decision governs. `/app/docs/report_spec.json` remains the contract for schemas, exact key sets, checksum serialization and digest payloads only.

## Bucketwatch Signal Findings (triage symptoms, not remediation guidance)
Responder note: timestamp mismatch reports recur across console replays, but the notes disagree about which stage introduced the discrepancy.
Responder note: the triage queue has missing pages under some severity mixes; operators did not isolate the responsible predicate.
Responder note: replay ordering is inconsistent between captures even when the underlying object set is unchanged.
Responder note: mixed-case detector labels diverged across the summary and paging artifacts.
Responder note: duplicate identifiers produced competing replay objects and unstable aggregate totals.
Responder note: dismissed objects leaked into triage-facing output in several snapshots.

## Initial Triage Notes (2026-03 — superseded)
Lead analyst recommended switching to CSV export and disabling escalated.jsonl paging until cache refresh SLO recovered. Replay against bundled events.json showed the pipeline miscounts even on cold cache. Do not implement CSV fallback for this incident.

## Preliminary Hypotheses (2026-03 — mostly wrong)
- Dashboard read replica lag causing stale signal counts (disproved: direct pipeline export shows same wrong counts)
- Missing accessed_at metadata in upstream feed (disproved on replay against bundled events.json)
- Risk-priority rows intentionally excluded by design (disproved on replay against bundled events.json)

## Attestation Console Archive (noise, non-authoritative)
Use this section as context only; acceptance is governed by `/app/data/events.json`, `/app/workflow/export_report.py`, and `/app/docs/report_spec.json`.

### Window 001 - acquirer beta
Pager showed transient bucket jitter during hourly rebalance.

### Window 002 - acquirer gamma
Ops notes mention manual replay activity and stale dashboard tiles.

### Window 003 - acquirer corvus
Console team discussed duplicate payout shadows from replay queues.

### Window 004 - acquirer atlas
Finance raised concern about delayed closeout rows.

### Window 005 - acquirer coral
Intermittent queue lag caused triage confusion.

### Window 006 - acquirer alpha
Responder shift reported inconsistent priority alias casing in inbound objects.

### Window 007 - acquirer beta
Attestation operator saw duplicate transaction identifiers across reprocessed batches.

### Window 008 - acquirer gamma
Some high-severity rows were dismissed by analysts but still surfaced downstream.

### Window 009 - acquirer corvus
Console participants escalated mismatch between on-call queue and exported escalated rows.

### Window 010 - acquirer atlas
Incident lead requested immutable snapshot handling during repair tasks.

### Window 011 - acquirer coral
Night shift reported reduced signal quality from oldest-first sort behavior.

### Window 012 - acquirer alpha
Triagers highlighted risk-level objects missing from signal exports.

### Window 013 - acquirer beta
A replay job introduced duplicate object_id rows with newer timestamps.

### Window 014 - acquirer gamma
Signal dashboard drifted from raw ledger feed.

### Window 015 - acquirer corvus
Case review found dismissed objects still visible to incident triagers. Policy states dismissed objects are excluded.

### Window 016 - acquirer atlas
Field mapping audit identified ambiguity between accessed_at and accessed_ms labels in legacy comments.

### Window 017 - acquirer coral
Console transcripts captured repeated requests for deterministic output keys and stable schema ordering.

### Window 018 - acquirer alpha
Ops manager requested no hardcoded counters in summary outputs.

### Window 019 - acquirer beta
Responder runbook confirmed signals include both high and critical priorities during triage windows.

### Window 020 - acquirer gamma
Service owners warned against patching snapshot artifacts.

## Console shift archive (2025-Q4 through 2026-Q2)

### Console shift 0014 — eta lane
> **Triage proposal (2026-02-09 - #OBJ-4907)** Tomas: objects whose accessed_ms will not parse as an integer should be dropped from the export entirely *(Superseded — reversed in the 2026-05 Bucketwatch review; see the matching decision entry.)*

### Console shift 0025 — beta lane
> **Triage proposal (2026-02-12 - #OBJ-4911)** Tomas: treat any non-empty dismissed string as true, including 'false' and 'no' *(Superseded — reversed in the 2026-05 Bucketwatch review; see the matching decision entry.)*

### Console shift 0036 — epsilon lane
> **Triage proposal (2026-02-15 - #OBJ-4914)** Dana: when an object_id repeats, keep the first row encountered and discard the rest *(Superseded — reversed in the 2026-05 Bucketwatch review; see the matching decision entry.)*

### Console shift 0047 — theta lane
> **Triage proposal (2026-02-18 - #OBJ-4917)** Dana: override rows with unrecognized severity_scope values should be normalized to scope 'all' so no window is lost *(Superseded — reversed in the 2026-05 Bucketwatch review; see the matching decision entry.)*

### Console shift 0058 — gamma lane
> **Triage proposal (2026-02-21 - #OBJ-4921)** Tomas: override intervals that merely touch should remain separate segments; only strict overlap merges *(Superseded — reversed in the 2026-05 Bucketwatch review; see the matching decision entry.)*

### Console shift 0059 — delta lane
> **Triage proposal (2026-02-22 - #OBJ-4927)** Dana: override suppression should use an inclusive window — an object whose accessed_ms equals a window's end_ms is still inside the override and must be suppressed (start_ms <= accessed_ms <= end_ms) *(Superseded — reversed in the 2026-05 Bucketwatch review; see the matching decision entry.)*

### Console shift 0062 — eta lane
> **Triage proposal (2026-02-23 - #OBJ-4929)** Tomas: total_objects should count only exported rows, so dismissed objects are excluded from total_objects as well as from the escalated export *(Superseded — reversed in the 2026-05 Bucketwatch review; see the matching decision entry.)*

### Console shift 0069 — zeta lane
> **Triage proposal (2026-02-24 - #OBJ-4924)** Dana: chain edges should require BOTH a matching bucket and two shared detector tokens *(Superseded — reversed in the 2026-05 Bucketwatch review; see the matching decision entry.)*

### Console shift 0071 — theta lane
> **Ops decision (2026-04-12 - #OBJ-5031)** Nadia: chain_risk_score = sum of member severity ranks (critical=4, high=3) + distinct_bucket_count + chain_span_ms // 100. *(Revised — see the 2026-05 decision log.)*

### Console shift 0073 — beta lane
> **Ops decision (2026-04-16 - #OBJ-5034)** Nadia: reach propagation — chain_reach_score = chain_risk_score + the single largest incoming edge_weight (best predecessor edge); the predecessor's own chain_reach_score is not accumulated. *(Revised — see the 2026-05 decision log.)*

### Console shift 0075 — delta lane
> **Ops decision (2026-04-20 - #OBJ-5037)** Marta: reach propagation tie-break — when two paths reach the same strongest_path_score, keep the one with the fewer chains (smaller chain_reach_depth); if still tied, keep the earlier-discovered path. *(Revised — see the 2026-05 decision log.)*

### Console shift 0077 — zeta lane
> **Ops decision (2026-04-24 - #OBJ-5029)** Nadia: reach graph edge weight = 2 + shared_asset_count + 2 * shared_detector_token_count; there is no gap-based bonus term. *(Revised — see the 2026-05 decision log.)*

### Console shift 0078 — eta lane
> **Ops decision (2026-04-06 - #OBJ-5010)** Imran: accessed_ms values are coerced to int after trimming, but rows whose value still will not parse are dropped from the canonical set and excluded from all totals. *(Revised — see the 2026-05 decision log.)*

### Console shift 0079 — theta lane
> **Ops decision (2026-04-28 - #OBJ-5019)** Imran: dedupe tie-break — keep the row with highest accessed_ms, then prefer dismissed=false over dismissed=true, then higher severity rank, then lexicographically larger normalized detector. Muted state is compared before severity rank. *(Revised — see the 2026-05 decision log.)*

### Console shift 0081 — beta lane
> **Ops decision (2026-04-14 - #OBJ-5041)** Imran: detector handling — trim only leading and trailing whitespace; internal spacing between tokens is preserved exactly as received. *(Revised — see the 2026-05 decision log.)*

### Console shift 0082 — gamma lane
> **Ops decision (2026-04-18 - #OBJ-5043)** Marta: chain correlation edge rule — create an edge between two candidates only when their bucket matches AND their detector token sets share at least two tokens (both conditions required). *(Revised — see the 2026-05 decision log.)*

### Console shift 0083 — delta lane
> **Ops decision (2026-04-22 - #OBJ-5045)** Imran: dedupe tie-break — after highest accessed_ms and severity rank, break remaining ties by the lexicographically SMALLER normalized detector, then the lexicographically smaller normalized bucket. *(Revised — see the 2026-05 decision log.)*

### Console shift 0084 — epsilon lane
> **Ops decision (2026-04-08 - #OBJ-5014)** Nadia: on an accessed_ms tie during dedupe, prefer the non-dismissed row first, and only then compare severity rank. *(Revised — see the 2026-05 decision log.)*

### Console shift 0090 — gamma lane
> **Ops decision (2026-04-10 - #OBJ-5021)** Marta: override pressure divisors are 25 for all-scope overlap and 15 for severity-scope overlap. *(Revised — see the 2026-05 decision log.)*

### Console shift 0096 — alpha lane
> **Ops decision (2026-04-12 - #OBJ-5027)** Imran: chain reach edge weight is 1 + shared_asset_count + shared_detector_token_count, with no gap bonus. *(Revised — see the 2026-05 decision log.)*

### Console shift 0110 — eta lane
> **Ops decision (2026-05-02 - #OBJ-5102)** Nadia: accessed_ms handling: coerce accessed_ms to int (trim string whitespace before int conversion; invalid values become 0). Rows with an unparseable value are KEPT with the fallback — they are not dropped. This supersedes #OBJ-4907 and revises the 2026-04 interim position in #OBJ-5010.

### Console shift 0129 — beta lane
> **Ops decision (2026-05-02 - #OBJ-5103)** Nadia: severity handling: strip surrounding whitespace then lowercase severity strings before counting and signal. bucket handling: strip surrounding whitespace then lowercase bucket names before grouping. dismissed handling: treat boolean-like strings ('true','1','yes') as true; every other string is false. This supersedes #OBJ-4911.

### Console shift 0148 — epsilon lane
> **Ops decision (2026-05-03 - #OBJ-5105)** Imran: detector handling: normalize detector by collapsing internal whitespace to single spaces before tie-breaks and output.

### Console shift 0167 — theta lane
> **Ops decision (2026-05-03 - #OBJ-5106)** Imran: dedupe: collapse duplicate object_id rows, keeping the row with highest accessed_ms; tie-break by higher severity rank (critical > high > medium > low), then prefer dismissed=false over dismissed=true, then lexicographically larger normalized detector, then lexicographically larger normalized bucket. Severity rank is compared before dismissed state — this supersedes #OBJ-4914 and revises the ordering in #OBJ-5014.

### Console shift 0186 — gamma lane
> **Ops decision (2026-05-04 - #OBJ-5108)** Marta: override scope: override severity_scope uses str(...).strip().lower(); supported values are all, high, critical. Rows whose normalized severity_scope is anything else (for example debug or an empty string) are DROPPED ENTIRELY before compaction — they contribute nothing to compacted windows, matching, pressure scores, or the override compaction checksum. This supersedes #OBJ-4917.

### Console shift 0205 — zeta lane
> **Ops decision (2026-05-04 - #OBJ-5109)** Marta: override windows: override windows come from /app/data/dismissal_overrides.json; normalize bucket and severity_scope, coerce start_ms/end_ms with accessed_ms rules, drop end_ms<=start_ms, then sort and compact per (bucket,severity_scope). Merge rule: merge when next.start_ms <= current.end_ms, so touching intervals merge. An equivalent implementation starts a new segment only when next.start_ms > current.end_ms; that '>' branch does not mean touching intervals remain separate. This supersedes #OBJ-4921.

### Console shift 0224 — alpha lane
> **Ops decision (2026-05-05 - #OBJ-5111)** Nadia: override matching: an signal candidate is suppressed when start_ms <= accessed_ms < end_ms for same normalized bucket and matching severity_scope in {all, candidate.severity}. The window is half-open: an object whose accessed_ms equals end_ms is NOT suppressed. This supersedes #OBJ-4927.

### Console shift 0243 — delta lane
> **Ops decision (2026-05-05 - #OBJ-5112)** Nadia: totals and export: total_objects — count canonical deduped objects (dismissed rows remain in totals; dismissed affects only the escalated export, never total_objects). This supersedes #OBJ-4929. Escalated export — include high and critical only, exclude dismissed=true, exclude candidates suppressed by override_match_rule, then annotate chains and directed reach before final sorting.

### Console shift 0262 — eta lane
> **Ops decision (2026-05-06 - #OBJ-5114)** Imran: override pressure: for each included signal row, compute all_overlap_ms using [accessed_ms-120, accessed_ms+1) against scope=all windows and severity_overlap_ms against scope=event severity windows; score=(all_overlap_ms//47)+(severity_overlap_ms//53). The 47/53 divisors are final and revise the interim 25/15 pair in #OBJ-5021.

### Console shift 0281 — beta lane
> **Ops decision (2026-05-07 - #OBJ-5116)** Marta: chain correlation input: final undismissed, unsuppressed high/critical signal candidates before final sorting. Signature tokens: lowercase normalized detector split on whitespace into a set. Edge rule: create an undirected edge between two candidates when abs(accessed_ms difference) <= 600 and either bucket matches or their detector token sets share at least two tokens. chains are full connected components of the undirected graph, not only direct neighbors. This supersedes #OBJ-4924.

### Console shift 0300 — epsilon lane
> **Ops decision (2026-05-07 - #OBJ-5117)** Marta: chain fields: chain_object_ids — component object ids converted to strings and sorted lexicographically. chain_size — number of rows in the connected component. chain_span_ms — maximum accessed_ms minus minimum accessed_ms in the component. chain_risk_score — sum severity ranks (critical=4, high=3) + 2*distinct_bucket_count + chain_span_ms//60.

### Console shift 0319 — theta lane
> **Ops decision (2026-05-08 - #OBJ-5119)** Nadia: reach graph nodes: one node per chain; start_ms=min member accessed_ms, end_ms=max member accessed_ms, assets=set of member buckets, tokens=union of lowercase whitespace-split member detectors. Node order: ascending (start_ms, end_ms, chain_id). Edge rule: directed predecessor->current when gap_ms=current.start_ms-predecessor.end_ms is in [1,3000] and chains share at least one asset or detector token. Edge weight: 1 + 2*shared_asset_count + shared_detector_token_count + max(0, 3-gap_ms//1000). This weighting revises #OBJ-5027, which lacked the doubled asset term and the gap bonus.

### Console shift 0320 — alpha lane
> **Incident note (2026-04-11 - #EXF-4401)** Nadia: broken rollup reads event['accessed_at'] instead of event['accessed_ms'], so signal timestamps collapse to zero in escalated output.

### Console shift 0338 — gamma lane
> **Ops decision (2026-05-08 - #OBJ-5120)** Nadia: reach propagation: strongest_path_score — chain_risk_score for a source; otherwise maximize predecessor.chain_reach_score + edge_weight + current.chain_risk_score across incoming edges, also allowing the current chain alone. Tie break: for equal strongest_path_score choose lexicographically smallest tuple of chain_id values in the complete path. chain_reach_path — chosen chain_id path including current chain; chain_reach_depth — len(chain_reach_path)-1.

Shift handover noted the escalation queue was being read without any notion of sustained load, so consecutive bursts on one asset group looked identical to isolated spikes.

> **Ops draft (2026-03-02 - #OBJ-4931)** Rao: escalation pressure — walk the escalated rows in export order carrying a running total; escalation_pressure = chain_risk_score + carry_in // 3 with the credit floored, carry decays by gap_ms // 200, carry_out caps at 100, and a row is escalation-critical at escalation_pressure >= 20. *(Superseded — reversed in the 2026-05 review; see the matching decision.)*

> **Ops interim (2026-04-14 - #OBJ-5044)** Priya: escalation pressure interim — the decay divisor moves to 150 and the critical threshold to 22; the floored credit, the 100 cap and the debit-free carry_out of #OBJ-4931 are retained pending the May review. *(Revised — see the 2026-05 review.)*

> **Ops decision (2026-05-09 - #OBJ-5122)** Nadia: escalation-pressure ledger (final). Walk the signal rows in the same order they are written to escalated.jsonl, carrying state between consecutive rows; the carry starts at 0. For each row: gap_ms is the previous row's accessed_ms minus this row's accessed_ms, floored at 0 (the export order is accessed_ms descending, so this is the elapsed distance between neighbours); carry_in = max(previous_carry_out - (gap_ms // 150), 0); escalation_pressure = chain_risk_score + ceil(carry_in / 3) — the carry credit is divided by three and ROUNDED UP, not floored, which is the point revised from #OBJ-4931 and left open by #OBJ-5044 (in integer arithmetic ceil(x/3) is -(-x // 3)); carry_out = min(carry_in + chain_risk_score - (chain_size // 2), 58) — note the chain-size debit and the 58 cap, both revising the earlier 100 cap and its absent debit. A row is escalation-critical when escalation_pressure >= 20. Only the carry credit rounds up; the gap decay and the chain-size debit are floored. This supersedes #OBJ-4931 and #OBJ-5044.

> **Ops decision (2026-05-09 - #OBJ-5123)** Nadia: escalation ledger reporting. critical_escalation_ids — object_id values of the escalation-critical rows as strings, sorted lexicographically ascending (not in export order). critical_escalation_count — their number. max_escalation_pressure — the largest escalation_pressure over all signal rows, escalation-critical or not, and 0 when there are no signal rows. escalation_ledger_checksum — SHA-256 hex digest of one line per signal row in export order, each `object_id|escalation_pressure|c|carry_out` where c is 1 for an escalation-critical row and 0 otherwise, lines joined by a single newline with no trailing newline, hashed over the UTF-8 encoding.
> **Board decision (2026-06-02 - #OBJ-5390)** Halvorsen: near dismissal probe. Each escalated signal carries a NEAR probe over the half-open range [accessed_ms - 120, accessed_ms + 1), measured separately against the `all`-scoped dismissal windows and against the windows recorded for the signal's own severity scope. `override_pressure_score = (all_overlap_ms // 47) + ceil(severity_overlap_ms / 53)`. The all half keeps its FLOOR and the scoped half ROUNDS UP. ROUNDING: all_overlap_ms // 47 = FLOOR. ROUNDING: severity_overlap_ms // 53 = CEIL.
> **Board decision (2026-06-02 - #OBJ-5392)** Halvorsen: wide dismissal probe. The WIDE probe uses the range [accessed_ms - 300, accessed_ms + 1) and its halves round in the OPPOSITE directions to the near probe: `wide_pressure_score = ceil(wide_all_overlap_ms / 59) + (wide_severity_overlap_ms // 55)`. No direction here may be inferred from the near family. `pressure_index = override_pressure_score + wide_pressure_score`, and the index is appended to the signal digest payload immediately after `override_pressure_score`. ROUNDING: wide_all_overlap_ms // 59 = CEIL. ROUNDING: wide_severity_overlap_ms // 55 = FLOOR.

> **Board decision (2026-06-14 - #OBJ-5398)** Halvorsen: chain-influence fixed point and the final escalation-pressure formula (this is now the latest word on the ledger and supersedes the #OBJ-5123 pressure term). Alongside the directed reach graph, build an UNDIRECTED chain-influence graph over the same chain nodes (one node per chain, carrying its start_ms, end_ms, member buckets and member detector tokens). Two DISTINCT chains are coupled when they share at least one bucket or at least one detector token AND their interval gap `gap_ms = max(0, max(start_ms) - min(end_ms))` taken across the two chains is <= 2500; the coupling weight is `2 + shared_bucket_count + 2*shared_detector_token_count`, with NO gap-based term (deliberately different from the directed-reach edge weight). Compute `chain_influence_score` as the fixed point of a SYNCHRONOUS (Jacobi) iteration: initialise every chain's influence to its `chain_risk_score`; in each round compute, for all chains together, `influence_next[c] = chain_risk_score[c] + floor(best_incoming[c] / 3)`, where `best_incoming[c]` is the maximum over c's coupled neighbours n of `influence[n] + weight(c, n)` read from the PREVIOUS round's values, or 0 when c has no coupled neighbour. Every chain in a round is updated from the previous round only; an in-place (Gauss-Seidel) update that reads a neighbour already advanced in the same round is wrong and gives a different fixed point. Iterate until a full round changes no value; `chain_influence_score` is that converged value and `chain_influence_rounds` is the number of rounds that changed at least one value (0 when no chain has a coupled neighbour). ROUNDING: best_incoming // 3 = FLOOR. `chain_influence_digest` = first 12 lowercase SHA256 hex chars of `chain_id|chain_influence_score|chain_influence_rounds`. Reporting: the summary carries `max_chain_influence_score` (max over final signal rows, 0 when none) and `chain_influence_digest_checksum` (SHA256 over the per-row `chain_influence_digest` values joined by a single `|`), and each signal row in escalated.jsonl carries `chain_influence_score`, `chain_influence_rounds` and `chain_influence_digest`. Ledger: the per-row `escalation_pressure` gains a floored influence term and is now `escalation_pressure = chain_risk_score + ceil(carry_in / 3) + (chain_influence_score // 6)`. ROUNDING: chain_influence_score // 6 = FLOOR. Only the carry credit rounds up; the gap decay, chain-size debit and this influence term are all floored. The influence term affects `escalation_pressure` and the escalation-critical flag only; `carry_out` is unchanged and does NOT include it, so the carry chain still matches #OBJ-5123. The escalation-critical threshold stays `escalation_pressure >= 20`.

> **Board decision (2026-06-16 - #OBJ-5402)** Halvorsen: chain-influence rank. After the #OBJ-5398 fixed point converges, rank the chains GLOBALLY by their converged `chain_influence_score`: `chain_influence_rank` is the DENSE rank in DESCENDING score order taken across ALL chains together — the chain or chains with the highest score have rank 1, the next distinct score has rank 2, and so on with NO gaps, and chains that tie on score share the same rank. This is a GLOBAL ranking over the entire chain set, not a per-chain, per-component or per-neighbourhood value, and it cannot be derived from a single chain in isolation; a chain with no coupled neighbour still takes its place in the global order by its own score. Each signal row carries `chain_influence_rank`, and it is appended to the chain-influence digest payload immediately after `chain_influence_rounds`, so `chain_influence_digest` is now the first 12 lowercase SHA256 hex chars of `chain_id|chain_influence_score|chain_influence_rounds|chain_influence_rank`. The `chain_influence_digest_checksum` and every downstream summary, escalation and repair field follow from the updated digest. Nothing else about the fixed point, the score, `chain_influence_rounds` or the escalation ledger changes.

### Console shift 0340 — epsilon lane
> **Incident note (2026-04-11 - #EXF-4402)** Imran: signal export keeps only severity == 'critical' rows, but on-call queue expects both high and critical.

### Console shift 0360 — alpha lane
> **Incident note (2026-04-12 - #EXF-4403)** Marta: signal rows are sorted ascending by accessed_ms, but triage workflow requires descending recency.

### Console shift 0380 — epsilon lane
> **Incident note (2026-04-13 - #EXF-4410)** Nadia: source payloads include HIGH and Critical aliases; rollup must normalize to lowercase before routing.

### Console shift 0400 — alpha lane
> **Incident note (2026-04-13 - #EXF-4411)** Imran: duplicate object_id rows must collapse to the object with highest accessed_ms before aggregation.

### Console shift 0420 — epsilon lane
> **Incident note (2026-04-14 - #EXF-4412)** Marta: objects with dismissed=true must be excluded from escalated export, even for critical severity.

### Console shift 0440 — alpha lane
> **Incident note (2026-04-14 - #EXF-4413)** Nadia: please keep the frozen snapshot untouched and derive evidence from that original source, not from a patched copy.

---

# Extended governance record — Bucketwatch object-routing rollup

This record is context for reconstructing the signed-off compile behaviour. It narrates how each
stage of the rollup came to be governed the way it is, why earlier approaches were revised, and
where the authoritative wording lives. It does not restate the final formulas — those are fixed by
the dated change decisions above and by `/app/docs/report_spec.json`; where this narrative and a
dated decision disagree, the decision governs. Read it to understand intent and to locate the
right decision, not to shortcut the derivation.

## 1. Incident background

The object-routing rollup summarises bucket-access telemetry into a responder queue: which
anomalous object accesses across the monitored buckets warrant a page, how they cluster, and how
much sustained pressure each cluster carries. The February rollout replaced the compile host and
shipped a rebuilt pipeline that regressed on several stages at once. The regression was not a
crash — the pipeline kept producing a queue — which is why it survived the smoke checks. It was a
behavioural drift: the emitted queue no longer matched what the change-advisory board had signed
off across normalization, deduplication, the override windows, the pressure probes, the chain
graph, and the escalation ledger. Downstream, that surfaced as three visible symptoms: risk-level
objects missing from the signal export, dismissed rows still surfacing, and the signal dashboard
drifting from the raw ledger feed. Each symptom traced back to one or more of the six governed
defects catalogued in the diagnosis contract.

Because the drift was silent, the board reconstructed the intended behaviour from its own decision
history rather than from the rebuilt code. That history is deliberately long: the rollup was tuned
incrementally over dozens of console shifts, and several early proposals were reversed once their
effect on the live queue was measured. The authoritative behaviour is therefore the *latest* dated
decision for each stage, not the first mention and not the rebuilt pipeline.

## 2. The six governed defects

The diagnosis CLI reports six defects. Each corresponds to a specific place where the rebuilt
pipeline diverged from the governed behaviour.

- **wrong_source_field** — the rebuild read the access timestamp from the wrong event field, so
  ordering and the probe windows were computed against a value that does not track the real access
  time. The fix restores the governed timestamp source; the symptom was a queue whose ordering did
  not match the raw ledger.
- **risk_threshold_filter** — the rebuild narrowed the set of severities admitted to the signal
  stage, dropping rows the board considered risk-level. The fix restores the full governed severity
  coverage; the symptom was risk-level objects missing from the export.
- **recency_order** — the rebuild's sort was unstable with respect to the governed recency
  ordering, so equally-recent rows drifted. The fix restores the governed ordering keys in order.
- **risk_class_normalization** — mixed-case and whitespace-padded severity and bucket strings were
  compared without normalization, so `Critical`, `critical ` and `critical` diverged into separate
  classes. The fix restores the governed normalization.
- **dedupe_event** — duplicate `object_id` rows were collapsed by input order rather than by the
  governed tie-break chain, so which of two competing rows survived was non-deterministic. The fix
  restores the deterministic collapse.
- **benign_filter** — rows an analyst had dismissed still reached the signal stage. The fix
  restores the governed exclusion of dismissed rows.

Diagnosing a defect means naming it, quoting the governing decision that defines the correct
behaviour, and pointing at the place in the frozen original pipeline where the regression lives.
Repairing it means rebuilding the pipeline so the emitted queue matches the governed behaviour on
any input, not just the bundled sample.

## 3. Stage-by-stage governance history

### 3.1 Normalization

Normalization was the first stage the board pinned, because every later stage depends on it.
Severity and bucket strings arrive from several producers with inconsistent casing and stray
whitespace; the access timestamp arrives sometimes as an integer, sometimes as a numeric string,
occasionally as a float. The governed rule strips and lower-cases the string fields and coerces the
timestamp to an integer with a defined fallback. Early shifts debated whether to normalize before
or after deduplication; the board settled on normalizing first so that dedupe compares like with
like. The dismissed flag has its own coercion: only an explicit truthy set counts as dismissed, and
every other string is false — a rule introduced after a shift where the literal string `"false"`
was being read as truthy.

### 3.2 Deduplication and tie-breaks

Two rows share an `object_id` when the same access is reported by more than one detector. The board
collapses them to one, but *which* one survives is governed by an ordered tie-break chain, not by
input order. The chain was revised more than once: an early proposal took the maximum severity,
which an automated escalator then gamed by inflating severity before a human confirmed it, so a
later decision reversed the severity direction for duplicates. The full chain runs in a fixed order
— the exact keys and directions are in the dated decisions — and the important property is that it
is total and deterministic: reordering the input never changes the survivor.

### 3.3 Override windows and compaction

Analysts suppress known-benign access with dismissal-override windows, scoped either to all
severities or to a specific severity, per bucket. Overlapping windows for the same bucket and scope
are compacted into maximal non-overlapping intervals before they are used, and the compaction is
serialized into a checksum so the board can confirm two pipelines compacted identically. The
serialization order and delimiter are pinned exactly, because an off-by-one in the join changes the
checksum without changing the queue, which made early divergences hard to spot.

### 3.4 The near and wide pressure probes

Each surviving signal carries two override-pressure probes that measure how much dismissal-window
coverage sits just before the access instant. The near probe uses a short lookback; the wide probe
uses a longer one. The two families were tuned in separate sessions and — this is the subtlety the
board flagged explicitly — they do not round the same way. One family floors one half and rounds
the other half up; the other family reverses those directions. The decisions state each direction
separately and warn that neither may be inferred from the other. The divisors were retuned once
after profiling showed one half was dropping sub-divisor spikes while the other over-counted.

### 3.5 Chain correlation

Signals that are close in time and share a bucket or enough detector tokens are unioned into
chains. Each chain carries a risk score built from its members' severities, its distinct-bucket
count, and its time span. The span term's divisor and the severity weights were both revised during
the May cycle; the earlier April values are superseded. A chain digest fixes the chain's identity so
two pipelines can be compared chain-by-chain.

### 3.6 Directed reach

Reach propagates risk along a directed graph of chains ordered in time: a chain inherits pressure
from the single strongest incoming predecessor edge. An early proposal accumulated the
predecessor's own reach as well, which double-counted long chains; a later decision restricted it to
the single best incoming edge weight without accumulating the predecessor's reach. The edge weight
combines shared buckets, shared detector tokens, and a decaying time-gap bonus.

### 3.7 Chain influence (fixed point)

Influence is the one stage that is not a single pass. It iterates: every chain's influence is its
own risk plus a floored fraction of the best neighbour's influence, recomputed round after round
until nothing changes. The number of rounds is itself an emitted value, and it is zero when no
chain has a coupled neighbour — a case worth checking, because a pipeline that always reports at
least one round has misread the convergence. Influence also carries a dense rank across the distinct
influence scores. Both the round count and the rank are folded into the influence digest.

### 3.8 Escalation ledger

The ledger walks the signals in emitted order, carrying pressure between consecutive rows. The
carry decays with the observed gap and is capped; each row's escalation pressure combines its chain
risk, a fraction of the carried-in pressure, and a fraction of the chain's influence. The rounding
directions here are mixed and are stated in the governing decision: one term rounds up while the
decay and the size debit round down. A row escalates when its pressure crosses the governed
threshold, and the ledger is serialized into a checksum row-by-row. The threshold, the cap and the
divisors were all touched during the May review; earlier drafts are superseded.

### 3.9 Priority, ordering and the queue cap

The final queue is ordered by a long list of keys applied strictly in sequence, and then capped per
bucket by the global order. The ordering key list and the cap were both revised to their final form
in the May cycle. The cap retains the highest-ordered rows per bucket rather than the earliest.

## 4. Deployment recovery context

The same rollout also left the compile host degraded: a non-executable operator wrapper pointing at
a path that no longer exists, a stale run lock, no schedule entry, a world-writable output
directory, a world-writable and root-owned log directory, no rotation drop-in, and an unrotated
leftover from the crashed run. The deployment runbook defines the required end state for each of
these. The scheduled compile must run and rotate under its own service account, not as root, and
the operator wrapper must be lock-aware so a second invocation while a compile is in flight exits
cleanly rather than double-running.

## 5. Acceptance and verification guidance

Acceptance is behavioural and is governed by the bundled `/app/data/events.json`, the repaired
`/app/workflow/export_report.py`, and `/app/docs/report_spec.json`. The compile must be
deterministic across reruns and correct on an alternate event stream it has not seen, so every
value must be derived from the inputs and the governing decisions — never hardcoded, and never
copied from a precomputed or expected-output file. The frozen reference snapshot at
`/app/workflow/.export_report.original` is read-only and must be left byte-for-byte unchanged; it
exists so the diagnosis can point at the regression, not as a source to edit in place. Historical
console-shift chatter, migration threads and dashboard-lag tickets are context only and are not
authoritative for current JSON export acceptance.

## 6. Review timeline — selected console shifts

The following entries are the review events that actually bore on the compile contract. They are
recorded in the board's own words and are not interchangeable: each fixed, questioned or reversed a
specific behaviour. Where an entry references a decision ticket, that decision above is the
authoritative wording.

- **Shift 0102 — detector-token tuning.** After a week where unrelated accesses were unioning into
  one chain, the board tightened chain correlation to require either a shared bucket or at least two
  shared detector tokens. A single shared generic token (`read`, `list`) was found to over-link.
- **Shift 0114 — timestamp source regression caught late.** A rebuild candidate read the access time
  from a display-only field that lagged the real access by a variable amount. It passed the sample
  but reordered a production queue. This is the origin of the wrong_source_field defect class.
- **Shift 0121 — severity inflation by an escalator.** An automated escalator was inflating severity
  on duplicate reports before a human confirmed them, so taking the maximum severity on a duplicate
  systematically over-escalated. The board reversed the severity direction for duplicate tie-breaks.
- **Shift 0130 — override compaction checksum introduced.** Two pipelines were producing the same
  queue but different internal override state; the board added a compaction checksum so identical
  compaction could be confirmed independently of the queue.
- **Shift 0138 — near/wide probe split.** Profiling showed a single rounding direction on the
  override probes either dropped sub-divisor spikes or over-counted steady coverage depending on the
  divisor. The board split the probes into a near family and a wide family with deliberately opposite
  rounding, and warned in writing that the two directions must not be inferred from each other.
- **Shift 0146 — reach double-counting.** The first reach proposal accumulated the predecessor's own
  reach as well as the incoming edge, which inflated long chains. The board restricted reach to the
  single strongest incoming edge weight.
- **Shift 0152 — influence convergence.** The influence stage was made an explicit fixed-point
  iteration after a one-pass approximation was found to under-rank chains with long coupling paths.
  The round count was added as an emitted value, and the board noted that it is zero when no chain
  has a coupled neighbour.
- **Shift 0159 — dismissed-string coercion.** The literal string `"false"` was being read as truthy
  by a naive boolean cast, so dismissed rows leaked. The board pinned an explicit truthy set and
  declared every other string false.
- **Shift 0164 — ledger threshold and cap.** The escalation threshold and carry cap were retuned
  after the queue was found to hold pressure too long across quiet gaps; the decay divisor and the
  chain-size debit were confirmed floored while the carry credit rounds up.
- **Shift 0170 — queue ordering finalized.** The coarse three-key ordering was replaced with the
  full ordered key list, and the per-bucket cap was defined to retain the highest-ordered rows
  rather than the earliest.
- **Shift 0178 — alternate-stream acceptance.** The board added the requirement that the compile be
  correct on an unseen event stream, to stop a candidate from fitting the bundled sample. This is
  why acceptance recomputes from inputs and rulings rather than from any stored expected output.
- **Shift 0185 — frozen snapshot protection.** After a candidate edited the reference pipeline in
  place to make the diagnosis pass, the board froze `/app/workflow/.export_report.original`
  read-only and made an unchanged snapshot part of acceptance.

## 7. Diagnosis appendix — evidence expectations

A diagnosis finding is accepted only when its evidence is specific. For each defect the report must
carry a verbatim quote of the governing decision (not a paraphrase), a pointer into the frozen
original pipeline showing where the regression lives, and a statement of the repair action. Vague
findings — "the pipeline is wrong here" — are rejected. The six defect ids are fixed; a report that
invents an id, omits one, or merges two into one is rejected. The diagnosis is stateless: the same
dossier always yields the same six findings, and the diagnose subcommand accepts only its two flags,
exiting non-zero and writing nothing on any other flag.

## 8. Non-authoritative material

The archived console-shift chatter, the historical CSV-migration threads, and the dashboard-lag
tickets that were attributed to stale cache refresh are retained elsewhere for provenance but are
explicitly non-authoritative for JSON export acceptance. They record that the pipeline was under
routine observation, not how it must behave. Acceptance is governed only by the bundled events, the
repaired pipeline, the report spec, and the dated decisions above. When chat excerpts and a dated
decision disagree, the decision governs; when two dated decisions disagree, the later one governs.

## 9. Boundary and edge-case catalog

These boundaries were each the subject of at least one review and are part of the governed
behaviour. They are stated as conditions, not as formulas; the exact constants remain with the dated
decisions.

- **Empty override set.** When no dismissal-override window applies to a bucket and scope, the
  override probes over that bucket contribute nothing and the compaction checksum for it is the
  checksum of the empty payload. A pipeline that special-cases the empty set differently from the
  general path diverges only on the checksum, which is why the empty case is called out explicitly.
- **Single-event stream.** With one admitted signal there are no neighbours, so chain influence
  converges in zero rounds and every reach edge is absent. The emitted round count must be zero
  here; a pipeline that reports one round has misread convergence as a single no-op pass.
- **All-dismissed stream.** If every anomalous row is dismissed, the signal stage is empty, the
  queue is empty, and the summary's maxima all fall back to their zero defaults rather than raising
  on an empty sequence. The dismissed-excluded count still reflects how many anomalous rows were
  held back.
- **Ties at every tie-break level.** Two duplicate rows can tie on timestamp, then on severity
  rank, then on the dismissed flag, then on detector, and finally on bucket. The tie-break chain is
  defined to a total order, so even a full tie resolves deterministically at the last key. Test
  inputs deliberately exercise a tie that only the final key breaks.
- **Sub-divisor probe coverage.** Override coverage smaller than a probe divisor contributes zero on
  a floored half and one on a ceilinged half. Because the near and wide families round their halves
  in opposite directions, the same small coverage can contribute differently to the two families —
  this is intended and is the reason the board warned the directions are independent.
- **Boundary of the escalation threshold.** A row whose escalation pressure equals the threshold
  escalates; a row one below does not. The threshold is a `>=` boundary, and inputs are built so at
  least one row sits exactly on it.
- **Carry decay to zero across a quiet gap.** When the observed gap between two consecutive emitted
  rows is large enough, the carried-in pressure decays to zero and the later row starts fresh. The
  decay is floored, so a gap just short of a full decay step still carries a residue.
- **Chain-size debit at odd sizes.** The chain-size debit on the carry is floored, so an odd chain
  size debits the same as the next even size below it. This was confirmed rather than rounded up,
  after a proposal to round it up was rejected for over-suppressing mid-size chains.
- **Reach path ordering.** When two predecessor edges tie on weight, the reach path is broken
  deterministically by chain identity so the emitted path and its digest are stable. Reordering the
  input never changes a chain's reach path.
- **Influence rank ties.** Distinct chains with equal influence scores share a dense rank; the rank
  is over distinct scores, not over chains, so three chains at two distinct scores occupy ranks one
  and two, not one through three.

## 10. Operational runbook cross-reference

The deployment recovery and the compile repair are independent deliverables that share a host. The
recovery brings the host to the runbook's end state — service account, lock-aware wrapper, schedule,
output and log ownership and modes, rotation, and cleanup of the crash leftovers — so that the
scheduled compile can run unattended under its own account. The repair brings the pipeline back to
the governed behaviour so that when it runs, its output is trustworthy. Neither substitutes for the
other: a correct pipeline scheduled on a broken host never runs, and a correctly scheduled host
running a broken pipeline ships a bad queue. Acceptance checks both independently.
