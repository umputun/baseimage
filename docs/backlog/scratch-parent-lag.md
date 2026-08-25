# base.scratch is built from the previous release's app image

`base.scratch/Dockerfile:1` is `FROM ghcr.io/umputun/baseimage/app:latest`. In
`.github/workflows/docker.yml` the `build` matrix runs app, buildgo and scratch in parallel
with no dependency between them, and pushes are digest-only. The `:latest` tag is written by
the `merge` job, and only on a tag build (`docker.yml:190-196` writes `:latest` in the tags
branch; a master push sets `:master` alone).

So scratch never sees the app image built beside it. It uses the last *tagged* release's app,
including during the tag build that publishes it.

Priority is low. At a roughly 6-month tag cadence the lag is one release against an Alpine
support window of about two years: 3.23 was released 2025-12-03 and reaches end of life
2027-11-01, 3.24 runs to 2028-06-01. The prep stage does `apk add -u tzdata ca-certificates`,
which fetches packages from the parent's branch at build time. At the current tag cadence the
lag stays well inside Alpine's support window and creates no practical EOL risk.

What it does cost:

- The scratch jobs in a PR that changes `base.alpine` prove only that the unchanged scratch
  definition still builds. They read as validating the Alpine change and do not.
- `scratch:<tag>` and `app:<tag>` from the same release are not built from the same Alpine
  base, so their provenance does not match.
- The repository commit does not identify scratch's prep-stage input, because the mutable
  `app:latest` digest is not recorded anywhere.

Possible fix: point the prep stage at `alpine:<version>` directly. No app-specific file is
copied into the final image - all five `COPY --from=prep` sources are either apk-installed in
prep (zoneinfo, `ca-certificates.crt`) or generated there (`passwd`, `group`, the compiled
`/nop`).

Two things the fix has to carry: `.github/dependabot.yml` has no `/base.scratch` entry, so a
direct Alpine parent there would be a version nothing watches and the entry has to be added in
the same change. And the resulting image is not byte-identical to today's, so the CA bundle,
zoneinfo, `/nop`, passwd/group and the app user need checking on both architectures.
