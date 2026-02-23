#!/bin/sh
set -eu

# this script provides access to scratch-based containers or any other container without a shell
# by temporarily copying busybox in and removing all of this on the exit

usage() {
    echo "Usage: dk.sh [-f] <container_name>" >&2
    echo "  -f  force busybox injection (skip shell detection)" >&2
    exit 1
}

FORCE=false

while getopts ":f" opt; do
  case $opt in
    f)
      FORCE=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done
shift $((OPTIND-1))

[ $# -eq 0 ] && usage

CONTAINER="$1"
id="$$" # use PID for unique file names to prevent collisions across concurrent runs
bbox_name="bbox_${id}"

if [ "$FORCE" = false ]; then
    # check for available shells, try each directly
    for shell in bash zsh ash sh; do
        if docker exec -it "$CONTAINER" $shell -c ls 1>/dev/null 2>/dev/null; then
            docker exec -it "$CONTAINER" $shell
            exit 0
        fi
    done
fi

# cleanup function to remove injected busybox and temp container
cleanup() {
    rm -f ./busybox
    docker exec -u 0 "$CONTAINER" /busybox.${id} sh -c "
/busybox.${id} rm -rf /busybin.${id}
/busybox.${id} rm -f /busybox.${id}
" 2>/dev/null || true
    docker rm -f "$bbox_name" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

# copy busybox into running container as /busybox.<random>
docker run -d --rm --name="$bbox_name" busybox:stable-musl sleep 30 1>/dev/null 2>/dev/null
docker cp "${bbox_name}":/bin/busybox .  1>/dev/null 2>/dev/null
docker cp ./busybox "$CONTAINER":/busybox.${id}  1>/dev/null 2>/dev/null
rm -f ./busybox

# install busybox inside the container
docker exec -u 0 -it "$CONTAINER" /busybox.${id} sh -c "
export PATH=/busybin.${id}
/busybox.${id} mkdir /busybin.${id} 2>/dev/null
/busybox.${id} --install /busybin.${id}
"

# invoke container shell
docker exec -it "$CONTAINER" /busybox.${id} sh -c "export PATH=/busybin.${id}; exec sh"
