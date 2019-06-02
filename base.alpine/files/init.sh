#!/sbin/dinit /bin/sh

uid=$(id -u)
if [[ ${uid} -eq 0 ]]; then
    echo "init container"

    # set container's time zone
    cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime
    echo "${TIME_ZONE}" >/etc/timezone
    echo "set timezone ${TIME_ZONE} ($(date))"

    # set UID for user app
    sed -i "s/:1001:1001:/:${APP_UID}:${APP_UID}:/g" /etc/passwd
    chown -R app:app /srv /home/app
fi


if [[ -f "/srv/init.sh" ]]; then
    echo "execute /srv/init.sh"
    chmod +x /srv/init.sh
    /srv/init.sh
    if [[ "$?" -ne "0" ]]; then
      echo "/srv/init.sh failed"
      exit 1
    fi
fi

echo "execute \"$@\""
if [[ ${uid} -eq 0 ]]; then
   su-exec app $@
else
   exec $@
fi
