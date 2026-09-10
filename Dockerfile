# CI image for services/deploy's GitLab pipeline. Bakes in everything
# .gitlab-ci.yml's before_script otherwise installs fresh on every job
# (ansible-core, the pinned collections, git, openssh-client, the
# python deps the inline scripts use) - that install path is what kept
# hanging on this fleet's runner (apt-get stuck on both `git` and
# `openssh-client` installs, more than once, at different points).
# Pulling one pre-built image sidesteps it entirely.
#
# Built by .github/workflows/build.yml and published to
# ghcr.io/j551n-ncloud/deploy-ci-image. Bump a pin here, push, and the
# next build carries it - no separate deploy-repo change needed unless
# .gitlab-ci.yml's own use of these tools changes.
FROM python:3.12-slim

# git: only roles's detect-changes job needs it (git diff against
# history) - GitLab's docker executor clones via its own helper image,
# so no job here needs git for checkout itself.
# openssh-client: .ansible_deploy needs it to reach hosts over SSH.
RUN apt-get update -qq \
    && apt-get install -y -qq --no-install-recommends \
       git \
       openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Same pin as requirements.yml's ansible-core comment there: an
# unbounded range could change deploy behaviour with no change in the
# deploy repo. Keep these two files' pins in sync by hand.
RUN pip install --no-cache-dir \
      "ansible-core>=2.16,<2.18" \
      requests \
      pyyaml

# Mirrors deploy/requirements.yml exactly - same upper-bound reasoning:
# community.docker's docker_compose_v2 parameters have shifted across
# majors, so pin, don't float.
RUN ansible-galaxy collection install \
      "community.docker:>=3.10.0,<6.0.0" \
      "ansible.posix:>=1.5.0,<3.0.0"

# Fails the build loudly if either pin resolved to something broken,
# rather than finding out on the next real deploy.
RUN ansible --version \
    && ansible-galaxy collection list \
    && git --version \
    && ssh -V \
    && python3 -c "import requests, yaml"
