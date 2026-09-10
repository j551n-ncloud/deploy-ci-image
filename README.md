# deploy-ci-image

CI image for the deploy repo's pipeline, ansible-core, git, openssh-client, and the collections, all baked in.

Used to install this fresh in every job, but that kept hanging on the runner (apt-get stuck on `git`, then later on `openssh-client`, no changes on our end). Pulling one pre-built image instead is just more reliable.

Published to `ghcr.io/j551n-ncloud/deploy-ci-image` by the Actions workflow here, and embedded in the deploy repo as a submodule.

## Bumping a pin

Edit the Dockerfile, push. It rebuilds `:latest` automatically. Then in `deploy`: `git submodule update --remote`, commit, done.
