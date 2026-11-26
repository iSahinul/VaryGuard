# AGENTS.md — VaryGuard

Single-file WordPress must-use plugin (`varyguard.php`) that keeps
content-negotiated variants (HTML vs `text/markdown`) from contaminating
each other in the page cache.

House rules:
- One file, no dependencies, no settings UI, no database writes. If a change
  needs a second file, justify it in the PR.
- Never cache the markdown variant by default. Changing that default is a
  breaking change and needs a major version bump.
- Be honest about the pre-PHP cache limit in docs; do not claim the plugin
  fixes caches it cannot intercept.
- WordPress hooks only; keep the code runnable on PHP 7.4+ / WP 5.8+.
- Fixtures and examples use example.com and invented names only.
