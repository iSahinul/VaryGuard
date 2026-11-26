#!/usr/bin/env bash
# VaryGuard diagnosis: is this site's negotiated content being contaminated
# by its page cache?
#
#   tests/diagnose.sh <page-url>
#
# Method (no marker string needed):
#   1. Fetch both variants from the ORIGIN (cache-busting query, so the
#      cache cannot answer) — if they are identical, the site does not
#      negotiate and VaryGuard does not apply.
#   2. Fetch both variants through the warm cache and compare bodies:
#      identical cached bodies on a negotiating origin = CONTAMINATED.
#
# Verdicts: NOT_APPLICABLE | CONTAMINATED | HEALTHY | MIXED (see hashes)
set -u

URL="${1:?usage: diagnose.sh <page-url>}"
BROWSER_ACCEPT="text/html,application/xhtml+xml"
MD_ACCEPT="text/markdown"
SEP='?vg_probe=origin'
case "$URL" in *\?*) SEP='&vg_probe=origin';; esac

body() { curl -s -H "Accept: $1" "$2"; }
hash() { printf '%s' "$1" | sha256sum | cut -d' ' -f1; }

echo "== Origin (cache bypassed) =="
ORIGIN_HTML="$(body "$BROWSER_ACCEPT" "$URL$SEP")"
ORIGIN_MD="$(body "$MD_ACCEPT" "$URL$SEP")"
if [ "$(hash "$ORIGIN_HTML")" = "$(hash "$ORIGIN_MD")" ]; then
  echo "Both variants are identical at the origin."
  echo "VERDICT: NOT_APPLICABLE — this page does not negotiate by Accept header."
  exit 0
fi
echo "Origin serves two different variants. Good — negotiation is on."

echo
echo "== Through the cache (warmed as a browser first) =="
body "$BROWSER_ACCEPT" "$URL" >/dev/null   # warm
CACHED_HTML="$(body "$BROWSER_ACCEPT" "$URL")"
CACHED_MD="$(body "$MD_ACCEPT" "$URL")"

echo "-- headers, browser variant:"
curl -sI -H "Accept: $BROWSER_ACCEPT" "$URL" | grep -iE '^(vary|cache-control|age|x-cache|cf-cache-status):' || true
echo "-- headers, markdown variant:"
curl -sI -H "Accept: $MD_ACCEPT" "$URL" | grep -iE '^(vary|cache-control|age|x-cache|cf-cache-status):' || true

H_CACHED_HTML="$(hash "$CACHED_HTML")"; H_CACHED_MD="$(hash "$CACHED_MD")"
H_ORIGIN_HTML="$(hash "$ORIGIN_HTML")"; H_ORIGIN_MD="$(hash "$ORIGIN_MD")"
echo
echo "body hashes: cached_html=$H_CACHED_HTML cached_md=$H_CACHED_MD"
echo "             origin_html=$H_ORIGIN_HTML origin_md=$H_ORIGIN_MD"

if [ "$H_CACHED_HTML" = "$H_CACHED_MD" ]; then
  echo "VERDICT: CONTAMINATED — both classes receive the same cached body."
  exit 2
fi
if [ "$H_CACHED_HTML" = "$H_ORIGIN_HTML" ] && [ "$H_CACHED_MD" = "$H_ORIGIN_MD" ]; then
  echo "VERDICT: HEALTHY — each class receives its own variant from a warm cache."
  exit 0
fi
echo "VERDICT: MIXED — cached bodies differ from each other but do not match"
echo "the origin exactly (dynamic elements?). Compare the bodies manually."
exit 3
