# Server snippets — keying a pre-PHP cache by variant

Use these when your page cache can serve a stored page before WordPress/PHP
runs (LiteSpeed server cache, Nginx FastCGI cache). VaryGuard's `Vary: Accept`
header already covers caches and CDNs that honour `Vary`; the snippets below
cover the ones that key on something explicit instead.

## LiteSpeed (with the LiteSpeed Cache plugin)

LiteSpeed honours the `Vary` response header at the server level, so in most
setups nothing further is needed. If you also enable VaryGuard's cookie mode
(`VG_VARY_COOKIE`), register the cookie as a cache vary so both variants are
stored separately:

1. WordPress dashboard → LiteSpeed Cache → Cache → **Cache Vary Cookies**:
   add `vg_variant`.
2. Purge the cache once after changing the setting.

## Nginx (FastCGI cache)

Enable VaryGuard's cookie mode, then include the cookie in the cache key:

```nginx
# Inside the server block that serves WordPress:
fastcgi_cache_key "$scheme$request_method$host$request_uri$cookie_vg_variant";
```

Requests without the cookie (first hit) share one key until the cookie is
set; VaryGuard sets it on the first response, so warmed variants separate
from the second hit onward. Validate with `test/warmed-cache-test.sh`.

## Apache / mod_cache

mod_cache honours `Vary` for stored responses. With `Vary: Accept` sent by
VaryGuard, no extra configuration is normally required.
