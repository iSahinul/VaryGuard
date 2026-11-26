<?php
/**
 * Plugin Name:       VaryGuard
 * Description:       Keeps content-negotiated variants (HTML for browsers, text/markdown for agents) from contaminating each other in the WordPress page cache: sends Vary: Accept, never lets the markdown variant into the page cache, and can set a vary cookie for caches that key on cookies.
 * Version:           0.1.0
 * Author:            Sahinul Islam Laskar
 * License:           GPL-2.0-or-later
 * License URI:       https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:       varyguard
 *
 * Install: copy this file to wp-content/mu-plugins/varyguard.php
 * (must-use plugins load on every request, before the theme and plugins,
 * which is where a cache guard has to live).
 *
 * What it does, in order:
 *   1. Detects the request variant from the Accept header:
 *      "text/markdown" anywhere in Accept -> variant "md", else "html".
 *   2. Adds "Vary: Accept" to every front-end response, so any cache or CDN
 *      that honours Vary keeps the variants in separate entries.
 *   3. Keeps the markdown variant OUT of the page cache by default
 *      (DONOTCACHEPAGE + Cache-Control: private, no-cache). Agents do not
 *      need cached copies; browsers keep full page caching. This removes
 *      the store-side half of the contamination entirely: a markdown
 *      response can never be stored under the URL and later served to a
 *      browser.
 *   4. Optional cookie mode: define VG_VARY_COOKIE as true in wp-config.php
 *      and VaryGuard sets a "vg_variant" cookie (md|html), so a cache that
 *      keys on cookies can hold both variants. See server-snippets.md for
 *      the matching LiteSpeed setting and Nginx cache-key line.
 *
 * Honest limit: a server cache that serves a stored page BEFORE PHP runs
 * and ignores Vary (and has no variant key configured) cannot be corrected
 * from inside WordPress. Steps 2 and 4 plus the snippets in
 * server-snippets.md cover the standard caches; the plugin says so rather
 * than pretending otherwise.
 */

if (!defined('ABSPATH')) {
    exit;
}

/**
 * The variant for this request: "md" when the client asked for markdown,
 * "html" otherwise. Computed once per request.
 */
function vg_variant()
{
    static $variant = null;
    if ($variant !== null) {
        return $variant;
    }
    $accept = isset($_SERVER['HTTP_ACCEPT']) ? (string) $_SERVER['HTTP_ACCEPT'] : '';
    $variant = (stripos($accept, 'text/markdown') !== false) ? 'md' : 'html';
    return $variant;
}

/** True for ordinary front-end page views (not admin, AJAX, cron or REST). */
function vg_is_front_page_view()
{
    if (is_admin() || wp_doing_ajax() || wp_doing_cron()) {
        return false;
    }
    if (defined('REST_REQUEST') && REST_REQUEST) {
        return false;
    }
    return true;
}

// Step 3 (early): never let the markdown variant enter the page cache.
// DONOTCACHEPAGE is honoured by WP Rocket, LiteSpeed Cache, W3 Total Cache,
// WP Super Cache and most other page-cache plugins.
add_action('init', function () {
    if (!vg_is_front_page_view()) {
        return;
    }
    if (vg_variant() === 'md' && !defined('DONOTCACHEPAGE')) {
        define('DONOTCACHEPAGE', true);
    }
}, 0);

// Step 4 (optional): a vary cookie a cookie-aware cache can key on.
// Off unless VG_VARY_COOKIE is defined as true (e.g. in wp-config.php).
if (defined('VG_VARY_COOKIE') && VG_VARY_COOKIE) {
    add_action('init', function () {
        if (!vg_is_front_page_view() || headers_sent()) {
            return;
        }
        $want = vg_variant();
        $have = isset($_COOKIE['vg_variant']) ? (string) $_COOKIE['vg_variant'] : '';
        if ($have !== $want) {
            setcookie(
                'vg_variant',
                $want,
                time() + HOUR_IN_SECONDS,
                COOKIEPATH ? COOKIEPATH : '/',
                COOKIE_DOMAIN,
                is_ssl(),
                false
            );
            $_COOKIE['vg_variant'] = $want;
        }
    }, 1);
}

// Steps 2 + 3 (headers): Vary: Accept on front-end responses, and a
// private/no-cache header on the markdown variant as a second line of
// defence for caches that key on Cache-Control instead of DONOTCACHEPAGE.
add_filter('wp_headers', function ($headers) {
    if (!vg_is_front_page_view()) {
        return $headers;
    }
    $headers['Vary'] = isset($headers['Vary']) ? $headers['Vary'] . ', Accept' : 'Accept';
    if (vg_variant() === 'md') {
        $headers['Cache-Control'] = 'private, no-cache';
    }
    return $headers;
});
