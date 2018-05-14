#!/bin/sh
count=$(govendor list +missing +excluded +unused | wc -l | awk '{print $1}')

if [ "$count" -eq "0" ]; then
	exit 0
fi

govendor list +excluded +unused +external
exit 1
