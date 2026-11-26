# Contributing to VaryGuard

Thanks for considering it. This is a small project with a few firm
house rules — they exist because the tool runs on real sites, in front
of their real caches.

## Ground rules

- **One file.** The plugin stays a single dependency-free PHP file with
  no settings UI and no database writes. If a change needs a second
  file, justify it in the PR.
- **Never cache the markdown variant by default.** Changing that
  default is a breaking change and needs a major version bump.
- **Be honest about the pre-PHP limit.** A cache that serves before PHP
  and ignores `Vary` cannot be fixed from inside WordPress — docs must
  keep saying so, never claim otherwise.
- Fixtures and examples use example.com and invented names only.

## Getting set up

Clone the repo, then run the checks before changing anything:

```bash
php -l varyguard.php          # syntax check
bash -n tests/diagnose.sh tests/warmed-cache-test.sh
```

## Making a change

1. Open an issue first for anything bigger than a typo, so the direction
   can be agreed before you spend time on it.
2. Keep the change focused; explain the failing input, the expected
   result, and the behaviour after the change.
3. If you change behaviour, update the README, the skill and the
   CHANGELOG in the same PR.
4. Validate with `tests/diagnose.sh` and `tests/warmed-cache-test.sh`
   against a negotiating test page, and say in the PR what you ran.

Contributions are provided under the project's GPL-2.0-or-later license.
