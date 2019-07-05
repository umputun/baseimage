#!/sbin/dinit /bin/sh

uid=$(id -u)

if [[ ${uid} -eq 0 ]]; then
    echo "init container"

    # set container's time zone
    cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime
    echo "${TIME_ZONE}" >/etc/timezone
    echo "set timezone ${TIME_ZONE} ($(date))"

    # set UID for user app
    if [[ "${APP_UID}" -ne "1001" ]]; then
        echo "set custom APP_UID=${APP_UID}"
        sed -i "s/:1001:1001:/:${APP_UID}:${APP_UID}:/g" /etc/passwd
    else
        echo "custom APP_UID not defined, using default uid=1001"
    fi
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
