---
name: varyguard
description: Install and validate VaryGuard, the WordPress MU plugin that keeps Accept-negotiated variants (HTML / text-markdown) from contaminating each other in the page cache.
---

# VaryGuard — agent skill

## When this applies
A WordPress site serves different content by `Accept` header (e.g.
`text/markdown` for agents) behind a full-page cache, and one class of
client starts receiving the other class's cached variant.

## Install
1. Copy `varyguard.php` into `wp-content/mu-plugins/` on the target site.
2. Purge the page cache once.
3. (Optional) For cookie-keyed caches, add `define('VG_VARY_COOKIE', true);`
   to `wp-config.php` and apply the matching snippet from
   `server-snippets.md`.

## Validate
Run the warmed-cache test with a string that only the markdown variant
contains:

```sh
test/warmed-cache-test.sh <page-url> "<markdown-only marker>"
```

It must print PASS: browser → markdown → browser, each class receiving its
own variant from a warm cache.

## Limits to state, never hide
A pre-PHP cache that ignores `Vary` and has no variant key cannot be fixed
from inside WordPress; use the server snippets for that case.
