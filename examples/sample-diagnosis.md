# Sample diagnosis (fictional site)

What `tests/diagnose.sh` prints on a negotiating site whose cache is
contaminating the variants — and the four-line report the skill produces
after the fix. Names and hashes are invented.

## Before the fix

```text
== Origin (cache bypassed) ==
Origin serves two different variants. Good — negotiation is on.

== Through the cache (warmed as a browser first) ==
-- headers, browser variant:
vary: Accept-Encoding
cache-control: max-age=3600
x-cache: HIT
-- headers, markdown variant:
vary: Accept-Encoding
cache-control: max-age=3600
x-cache: HIT

body hashes: cached_html=9f2c…a1 cached_md=9f2c…a1
             origin_html=9f2c…a1 origin_md=41bd…7e
VERDICT: CONTAMINATED — both classes receive the same cached body.
```

## After installing VaryGuard and purging once

```text
Setup: negotiates (HTML / text-markdown) · cache: LiteSpeed, HITs served pre-PHP
Diagnosis: CONTAMINATED — markdown clients received the cached HTML body
Action: varyguard.php installed in wp-content/mu-plugins/, cache purged once
Verification: diagnose.sh HEALTHY · warmed-cache test PASS
```
