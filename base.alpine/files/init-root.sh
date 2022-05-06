#!/sbin/dinit /bin/sh

echo execute "$@" as root
exec "$@"