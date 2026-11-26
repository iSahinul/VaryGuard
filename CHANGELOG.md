# Changelog

All notable changes to VaryGuard are recorded here.
Format follows [Keep a Changelog](https://keepachangelog.com/); versions use
[Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-11-26

First public release.

- Single-file must-use plugin: detects the request variant from the
  `Accept` header, sends `Vary: Accept`, and keeps the markdown variant
  out of the page cache by default (`DONOTCACHEPAGE` +
  `Cache-Control: private, no-cache`)
- Optional vary-cookie mode (`VG_VARY_COOKIE`) for cookie-keyed caches,
  with LiteSpeed and Nginx snippets in `server-snippets.md`
- Diagnosis and warmed-cache test scripts in `tests/`
- Agent Skill (`skill/SKILL.md`) and `AGENTS.md` included
