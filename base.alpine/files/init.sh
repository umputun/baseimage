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
        sed -i "s/:1001:/:${APP_UID}:/g" /etc/group
    else
        echo "custom APP_UID not defined, using default uid=1001"
    fi

    # set GID for docker group
    if [[ "${DOCKER_GID}" -ne "999" ]]; then
        echo "set custom DOCKER_GID=${DOCKER_GID}"
        # check if another group already uses this GID
        existing_group=$(getent group "${DOCKER_GID}" | cut -d: -f1)
        if [[ -n "${existing_group}" && "${existing_group}" != "docker" ]]; then
            # reuse existing group - add app to it for socket access
            echo "GID ${DOCKER_GID} used by '${existing_group}', adding app to it"
            if ! addgroup app "${existing_group}"; then
                echo "error: failed to add app user to group '${existing_group}'"
                exit 1
            fi
        else
            # no collision - create docker group with requested GID
            delgroup docker 2>/dev/null || true
            if ! addgroup -g "${DOCKER_GID}" docker; then
                echo "error: failed to create docker group with GID=${DOCKER_GID}"
                exit 1
            fi
            if ! addgroup app docker; then
                echo "error: failed to add app user to docker group"
                exit 1
            fi
        fi
    else
        echo "custom DOCKER_GID not defined, using default gid=999"
    fi

    chown -R app:app /srv
    if [[ "${SKIP_HOME_CHOWN}" != "1" ]]; then
        chown -R app:app /home/app
    fi
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

echo execute "$@"
if [[ ${uid} -eq 0 ]]; then
   exec su-exec app "$@"
else
   exec "$@"
fi
