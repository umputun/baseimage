# Feature-branch push runs report green without building anything

`.github/workflows/docker.yml` triggers on both `pull_request` and
`push: branches: ["**"]`. On a push to any branch that is not master and not a tag,
every meaningful step in the `build` job is skipped:

- `build only (PR validation)` requires `github.event_name == 'pull_request'`
- both login steps, both build-and-push steps, digest export and both digest uploads
  require `github.event_name == 'push'` **and** master or a tag
- the `merge` job has the same master-or-tag condition

Measured on run 32895469028 (buildgo/amd64, PR #49 branch), step conclusions were:
checkout success, set up docker buildx success, steps 4 through 11 all `skipped`,
post-steps success. The job reports success having built no image.

Effect: every PR branch carries two runs on the same SHA. `gh pr checks <N>` aggregates
both and can report a full green matrix while the `pull_request` run is still building,
or while it has not run at all. That reads as validation and is not.

Any merge gate on this repo must name one run whose `event` is `pull_request`, whose
`headSha` equals the current PR head, whose conclusion is `success`, and whose six
image/platform build jobs each succeeded.

Possible fix: narrow the push trigger to master and tags, since branch pushes produce
no artifact and no validation. Needs a check for whether anything depends on a run
existing for arbitrary branches.
