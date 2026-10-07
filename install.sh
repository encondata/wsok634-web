#!/bin/sh
# Install / update the WSOK634 site as a Docker container.
#
# Asks where to keep the site code (default /mnt/user/wsok634_web), clones or
# updates the repo there, pulls the generic Alpine base image, builds the site
# into it, and (re)starts the container.
#
# Usage:  ./install.sh                                  # prompts, serves on port 8675
#         curl -fsSL <raw install.sh url> | sh          # same, from anywhere
#         INSTALL_DIR=/srv/wsok634 ./install.sh         # skip the prompt
#         PORT=8080 ./install.sh                        # serve on another port
set -eu

REPO_URL="${REPO_URL:-https://github.com/encondata/wsok634-web.git}"
IMAGE="${IMAGE:-wsok634-web}"
CONTAINER="${CONTAINER:-wsok634-web}"
PORT="${PORT:-8675}"
DEFAULT_DIR="/mnt/user/wsok634_web"
BASE_IMAGE="alpine:3.20"

command -v docker >/dev/null 2>&1 || { echo "docker is not installed" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { echo "git is not installed" >&2; exit 1; }

# Ask for the install location. Read from the terminal so this also works when
# the script is piped in (curl ... | sh); with no terminal, use the default.
if [ -z "${INSTALL_DIR:-}" ]; then
    if [ -r /dev/tty ] && (exec </dev/tty) 2>/dev/null; then
        printf 'Install location [%s]: ' "$DEFAULT_DIR" >/dev/tty
        read -r INSTALL_DIR </dev/tty || INSTALL_DIR=""
    fi
    INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_DIR}"
fi
SRC="$INSTALL_DIR"

if [ -d "$SRC/.git" ]; then
    echo "==> Updating $SRC"
    git -C "$SRC" pull --ff-only
elif [ -f "$SRC/Dockerfile" ] && [ -f "$SRC/index.html" ]; then
    echo "==> Using existing site files in $SRC"
elif [ -d "$SRC" ] && [ -n "$(ls -A "$SRC" 2>/dev/null)" ]; then
    echo "$SRC exists and is not empty; choose another location" >&2
    exit 1
else
    echo "==> Cloning $REPO_URL into $SRC"
    mkdir -p "$(dirname "$SRC")"
    git clone "$REPO_URL" "$SRC"
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
