#!/bin/sh

cd /srv

if [[ $# -eq 0 ]]; then
    export TERM=xterm-color
else
    export TERM=$1
fi

uid=$(id -u)
if [[ $uid -ne 0 ]]; then
   exec /bin/sh
fi

su app
