---
name: varyguard
description: Diagnose, fix and verify page-cache contamination on WordPress sites that negotiate content by Accept header (HTML for browsers, text/markdown for AI agents). Use when one class of client receives the other class's cached variant.
---

# VaryGuard — agent workflow: diagnose → fix → verify

You are working on a WordPress site that serves **two variants of the same
URL** by the `Accept` header (browsers get HTML; agents asking for
`text/markdown` get markdown), behind a full-page cache. The failure mode:
the cache stores the first variant and serves it to everyone.

Work the three phases in order. Do not skip diagnosis — the fix differs by
which half is broken, and some sites do not negotiate at all.

## Phase 1 — Diagnose

Run:

```sh
test/diagnose.sh <page-url>
```

It compares origin bodies (cache bypassed) against warm-cache bodies and
prints one verdict:

- `NOT_APPLICABLE` — the origin serves identical bodies for both Accept
  types. The site does not negotiate; stop and report that.
- `CONTAMINATED` — both classes receive the same cached body. Continue.
- `HEALTHY` — each class already receives its own variant. Stop; report.
- `MIXED` — cached bodies differ from the origin (dynamic content?). Fetch
  both cached bodies yourself, compare them against the origin bodies, and
  judge which class is being served the wrong variant before continuing.

Also note the printed headers: is `Vary: Accept` present? Does the cache
report HITs (`x-cache`, `age`, `cf-cache-status`)? You will compare these
after the fix.

## Phase 2 — Fix

Access needed: a way to write one file into the site's WordPress install
(SSH/SFTP, hosting file manager, or WP-CLI). If you only have wp-admin,
install `varyguard.php` as a regular plugin instead — it works, but tell
the owner the must-use route below is stronger, because cache drop-ins can
decide before regular plugins load.

1. Copy `varyguard.php` to `wp-content/mu-plugins/varyguard.php`.
2. Purge the page cache once, using whatever the site already runs
   (WP-CLI: `wp cache flush`, plus the cache plugin's own purge command if
   it has one; otherwise the plugin's purge button in wp-admin).
3. Nothing else changes: no settings, no database writes. Browsers keep
   full page caching; only the markdown variant is kept out of the cache,
   and `Vary: Accept` is added to front-end responses.

If the site's cache serves pages **before PHP** (LiteSpeed server cache,
Nginx FastCGI cache) and Phase 3 still fails, apply the matching line from
`server-snippets.md` — server config changes need a backup of the current
config and the site owner's explicit approval first. Never disable the
site's cache wholesale as a "fix".

## Phase 3 — Verify

Re-run `test/diagnose.sh <page-url>`. Then, for a stricter check, pick a
string that appears only in the markdown variant and run Ramil's test:

```sh
test/warmed-cache-test.sh <page-url> "<markdown-only marker>"
```

Report exactly four lines:

```
Setup: <negotiates / does not negotiate> · cache: <what served the HITs>
Diagnosis: <verdict from Phase 1>
Action: <what you installed/changed, or "none needed">
Verification: <diagnose.sh verdict + warmed-cache test PASS/FAIL>
```

## Honest limits — state them, never hide them

- A pre-PHP cache that ignores `Vary` and has no variant key configured
  cannot be fixed from inside WordPress; it needs the server snippet.
- Cookie mode (`VG_VARY_COOKIE`) is off by default; enable it only when a
  cookie-keyed cache is actually in play.
- If verification still fails after the plugin and the correct snippet,
  say so plainly with the evidence (hashes + headers) instead of claiming
  success.
