#!/bin/bash

if [ $# -eq 0 ]
  then
    export TERM=xterm-color
else
    export TERM=$1
fi

if [[ $EUID -ne 0 ]]; then
   exec /bin/bash
fi

su app
