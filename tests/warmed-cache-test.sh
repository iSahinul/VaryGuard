#!/usr/bin/env bash
# Warmed-cache variant test.
#
# The cross-contamination bug only appears AFTER the cache is warm, so this
# script warms it as a browser first, then checks both classes back-to-back:
#   1. browser request  (warms the cache with the HTML variant)
#   2. markdown request (Accept: text/markdown) — must contain the marker
#   3. browser request again — must NOT contain the marker
#
# Usage:
#   tests/warmed-cache-test.sh <url> <markdown-only-marker>
#
# The marker is any string that appears only in the markdown variant
# (for example its first heading without HTML tags).
set -u

URL="${1:?usage: warmed-cache-test.sh <url> <markdown-only-marker>}"
MARKER="${2:?usage: warmed-cache-test.sh <url> <markdown-only-marker>}"

BROWSER_ACCEPT="text/html,application/xhtml+xml"
MD_ACCEPT="text/markdown"

fetch() { curl -s -H "Accept: $1" "$URL"; }

echo "1/3 warming cache as a browser..."
fetch "$BROWSER_ACCEPT" >/dev/null || { echo "FAIL: page unreachable"; exit 1; }

echo "2/3 markdown request must contain the marker..."
if fetch "$MD_ACCEPT" | grep -qF "$MARKER"; then
  echo "    ok — markdown variant served to the markdown client"
else
  echo "FAIL: markdown client did not receive the markdown variant"
  exit 1
fi

echo "3/3 browser request must NOT contain the marker..."
if fetch "$BROWSER_ACCEPT" | grep -qF "$MARKER"; then
  echo "FAIL: browser received the markdown variant (cache contaminated)"
  exit 1
else
  echo "    ok — browser still receives the HTML variant"
fi

echo "PASS: each class receives its own variant from a warm cache"
