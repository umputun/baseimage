#!/bin/sh

# this script provides access to scratch-based containers ot any other container without shell
# by temporary copy busybox in. removes all of this on the exit

# check if sh is already available
if docker exec -it "$1" sh -c ls 1>/dev/null 2>/dev/null; then
    # check for available shells
    for shell in bash zsh ash sh; do
        if docker exec -it "$1" $shell -c ls 1>/dev/null 2>/dev/null; then
            docker exec -it "$1" $shell
            exit 0
        fi
    done
    exit 1
fi

id="$$" # randomize file names to prevent collisions if run multiple times

# copy busybox into running container as /busybox.<random>
docker run -d --rm --name=bbox busybox:stable-musl sleep 10 1>/dev/null 2>/dev/null
docker cp bbox:/bin/busybox .  1>/dev/null 2>/dev/null
docker cp ./busybox "$1":/busybox.${id}  1>/dev/null 2>/dev/null
rm -f ./busybox

# install busybox inside the container
docker exec -u 0 -it "$1" /busybox.${id} sh -c "
export PATH=/busybin.${id}
/busybox.${id} mkdir /busybin.${id} 2>/dev/null
/busybox.${id} --install /busybin.${id}
"

# invoke container shell
docker exec -it "$1" /busybox.${id} sh -c "export PATH=/busybin.${id}; exec sh"

# cleanup temp files on exit
docker exec -u 0 -it "$1" /busybox.${id} sh -c "
/busybox.${id} rm -rf /busybin.${id}
/busybox.${id} rm -f /sh.${id}
/busybox.${id} rm -f /busybox.${id}
"
