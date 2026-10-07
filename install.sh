#!/bin/sh
# Install / update the WSOK634 site as a Docker container.
#
# Pulls the generic Alpine base image, builds the site into it, and (re)starts
# the container. Run from a checkout of this repo, or anywhere — it will clone
# the repo if it isn't already in one.
#
# Usage:  ./install.sh                 # serve on port 8675
#         PORT=8080 ./install.sh       # serve on another port
set -eu

REPO_URL="${REPO_URL:-https://github.com/encondata/wsok634-web.git}"
IMAGE="${IMAGE:-wsok634-web}"
CONTAINER="${CONTAINER:-wsok634-web}"
PORT="${PORT:-8675}"
BASE_IMAGE="alpine:3.20"

command -v docker >/dev/null 2>&1 || { echo "docker is not installed" >&2; exit 1; }

# Find the site source: this script's directory if it's the repo, otherwise clone.
SRC="$(cd "$(dirname "$0")" && pwd)"
if [ ! -f "$SRC/Dockerfile" ] || [ ! -f "$SRC/index.html" ]; then
    SRC="${INSTALL_DIR:-$HOME/wsok634-web}"
    if [ -d "$SRC/.git" ]; then
        echo "==> Updating $SRC"
        git -C "$SRC" pull --ff-only
    else
        echo "==> Cloning $REPO_URL into $SRC"
        git clone "$REPO_URL" "$SRC"
    fi
fi

echo "==> Pulling base image $BASE_IMAGE"
docker pull "$BASE_IMAGE"

echo "==> Building $IMAGE"
docker build -t "$IMAGE" "$SRC"

if docker container inspect "$CONTAINER" >/dev/null 2>&1; then
    echo "==> Replacing existing container $CONTAINER"
    docker rm -f "$CONTAINER" >/dev/null
fi

echo "==> Starting $CONTAINER on port $PORT"
docker run -d --name "$CONTAINER" --restart unless-stopped -p "$PORT:80" "$IMAGE" >/dev/null

echo "==> Done. Site is at http://localhost:$PORT/"
