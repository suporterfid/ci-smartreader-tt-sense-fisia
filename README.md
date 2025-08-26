# ci-smartreader-tt-sense-fisia

This repository hosts a GitHub Actions workflow that builds the SmartReader
application together with the YTEM plugin and publishes a Docker image.
Frontend build artifacts are generated during the workflow and **are not
committed** to the repository.

## Combined Build Workflow (Option A)

The [`combined-build.yml`](.github/workflows/combined-build.yml) workflow
performs a full build of SmartReader including the YTEM plugin and smoke tests
the resulting container image.

1. Check out the plugin and SmartReader repositories using the `GH_PAT_READ`
   token.
2. Build the plugin with Node.js and copy the compiled assets into the
   SmartReader project.
3. Build a Docker image for SmartReader and push it to GitHub Container Registry
   (GHCR).
4. Run `scripts/smoke-test.sh` to ensure the container serves the plugin at
   `/ytem/`.

### Required secrets and permissions

- `GH_PAT_READ` – personal access token with **read** access to the plugin and
  SmartReader repositories.
- Optional registry credentials – only needed when pushing to a registry other
  than GHCR.

The workflow requires the following permissions:

```yaml
permissions:
  contents: read
  packages: write
```

### Triggers, caching, and smoke test

- Runs on `push` to the `main` branch and on manual `workflow_dispatch` events.
- Uses the `actions/setup-node` cache for Node.js dependencies and Docker
  BuildKit layer caching for faster image builds.
- Executes `scripts/smoke-test.sh` as a lightweight verification of the built
  image.

### Publishing images

Each run pushes images tagged with the commit SHA and `latest` to GHCR. To
publish a versioned tag after a run:

```bash
docker pull ghcr.io/suporterfid/smartreader:<sha>
docker tag ghcr.io/suporterfid/smartreader:<sha> ghcr.io/suporterfid/smartreader:v1.2.3
docker push ghcr.io/suporterfid/smartreader:v1.2.3
```

