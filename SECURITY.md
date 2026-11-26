# Security Policy

## Reporting a vulnerability

Please do **not** open a public issue for a security problem.
Use GitHub's private vulnerability reporting on this repository
(the **Security** tab → **Report a vulnerability**), or open a regular
issue saying only that you need a private channel — no details in public.

You can expect an acknowledgement within a few days. This is a small
open-source project maintained by one person; fixes ship as fast as
they reasonably can.

## Scope notes

- VaryGuard reads only the request's `Accept` header (and, in opt-in
  cookie mode, its own `vg_variant` cookie). It collects nothing, stores
  nothing, and makes no external requests.
- It deliberately does **not** weaken the destination or cache rules of
  the site it runs on: browsers keep full page caching, and the markdown
  variant is only ever made *less* cacheable, never more.
- Reports about a cache product's own behaviour belong with that product;
  reports about how VaryGuard's headers interact with a cache are in
  scope here.
