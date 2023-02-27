#!/bin/sh

# this script provides access to scratch-based containers by temporary copy busybox in.
# removes all of this on exit

id="$$" # randomize file names to prevent collisions if run multiple times

# copy busybox into running container as /busybox.<random>
docker run -d --rm --name=bbox busybox:latest sleep 10 1>/dev/null 2>/dev/null
docker cp bbox:/bin/busybox .
docker cp ./busybox "$1":/busybox.${id}
rm -f ./busybox

# install busybox inside the container
docker exec -u 0 -it "$1" /busybox.${id} sh -c "
export "PATH=/busybin.${id}"
/busybox.${id} mkdir /busybin.${id} 2>/dev/null
/busybox.${id} --install /busybin.${id}
"

# make shell script with busybin path and copy it in
script="
export "PATH=/busybin.${id}"
sh
"
echo "$script" > sh.${id}
chmod +x sh.${id}
docker cp sh.${id} "$1":/sh.${id}
rm -rf sh.${id}

# invoke container shell
docker exec -it "$1" /busybox.${id} sh -c /sh.${id}

# cleanup temp files on exit
docker exec -u 0 -it "$1" /busybox.${id} sh -c "
echo cleaning...
/busybox.${id} rm -rf /busybin.${id}
/busybox.${id} rm -f /sh.${id}
/busybox.${id} rm -f /busybox.${id}
"
