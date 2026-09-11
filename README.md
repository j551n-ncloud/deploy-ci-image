# deploy-ci-image

Two CI images, built from this one repo, one for each GitLab pipeline that needed to stop installing its own tooling fresh on every job:

- **`Dockerfile`** -> `ghcr.io/j551n-ncloud/deploy-ci-image` - ansible-core, git, openssh-client, and the collections `services/deploy`'s pipeline needs.
- **`Dockerfile.build`** -> `ghcr.io/j551n-ncloud/build-ci-image` - git, openssh-client on top of the `docker:27` base, for `services/build`'s pipeline (needs the docker CLI, not ansible).

Both exist for the same reason: installing this stuff fresh in every job kept hanging on the runner (apt-get stuck on `git`, then later on `openssh-client`, no changes on our end). Pulling one pre-built image instead is just more reliable.

Each is embedded in its own repo as a submodule (`deploy` and `build` respectively).

## Bumping a pin

Edit the relevant Dockerfile, push. Both jobs run on any push touching either Dockerfile (no per-path job filtering - both images are small and fast enough that rebuilding the one that didn't change isn't worth the extra workflow complexity). Then in whichever repo consumes it: `git submodule update --remote`, commit, done.
