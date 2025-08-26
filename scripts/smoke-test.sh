#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-${IMAGE:-}}"
PORT="${2:-${PORT:-}}"

if [[ -z "${IMAGE}" || -z "${PORT}" ]]; then
  echo "Usage: IMAGE=<image> PORT=<port> $0 [image] [port]"
  exit 1
fi

cleanup() {
  docker stop sr-test >/dev/null 2>&1 || true
}
trap cleanup EXIT

# Run container

docker run --rm -d -p "${PORT}:80" --name sr-test "${IMAGE}"

# Wait for container to become ready
ready=0
for _ in $(seq 1 30); do
  if curl -fsS "http://localhost:${PORT}/ytem/" >/dev/null; then
    ready=1
    break
  fi
  sleep 1
done

if [[ $ready -ne 1 ]]; then
  echo "Timed out waiting for container to become ready"
  docker logs sr-test || true
  exit 1
fi

# Verify endpoint returns HTTP 200
curl -f "http://localhost:${PORT}/ytem/" >/dev/null || {
  docker logs sr-test || true
  exit 1
}
