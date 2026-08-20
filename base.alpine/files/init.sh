#!/sbin/dinit /bin/sh

uid=$(id -u)

if [[ ${uid} -eq 0 ]]; then
    [[ "${INIT_QUIET}" != "1" ]] && echo "init container"

    # set container's time zone
    tz_set=1
    if ! cp "/usr/share/zoneinfo/${TIME_ZONE}" /etc/localtime; then
        echo "error: failed to set ${TIME_ZONE} in /etc/localtime, make sure the zone exists in /usr/share/zoneinfo and the file is writable"
        echo "warning: container keeps the timezone it already had ($(date))"
        tz_set=0
    fi
    if ! echo "${TIME_ZONE}" >/etc/timezone; then
        echo "error: failed to write ${TIME_ZONE} to /etc/timezone, programs reading it get a stale value"
        tz_set=0
    fi
    if [[ ${tz_set} -eq 1 ]] && [[ "${INIT_QUIET}" != "1" ]]; then
        echo "set timezone ${TIME_ZONE} ($(date))"
    fi

    # set UID for user app
    if [[ "${APP_UID}" -ne "1001" ]]; then
        [[ "${INIT_QUIET}" != "1" ]] && echo "set custom APP_UID=${APP_UID}"
        if ! sed -i "s/:1001:1001:/:${APP_UID}:${APP_UID}:/g" /etc/passwd; then
            echo "error: failed to update /etc/passwd, file is not writable"
        fi
        if ! sed -i "s/:1001:/:${APP_UID}:/g" /etc/group; then
            echo "error: failed to update /etc/group, file is not writable"
        fi
        # sed exits 0 even if nothing matched, check the result
        actual_uid=$(id -u app 2>/dev/null)
        if [[ "${actual_uid}" != "${APP_UID}" ]]; then
            echo "error: failed to set uid ${APP_UID} for the app user, it runs with uid=${actual_uid:-unknown}"
        fi
        actual_gid=$(id -g app 2>/dev/null)
        if [[ "${actual_gid}" != "${APP_UID}" ]]; then
            echo "error: failed to set gid ${APP_UID} for the app user, it runs with gid=${actual_gid:-unknown}"
        fi
        group_gid=$(getent group app | cut -d: -f3)
        if [[ "${group_gid}" != "${APP_UID}" ]]; then
            echo "error: failed to set gid ${APP_UID} for the app group, it stays gid=${group_gid:-unknown}"
        fi
    else
        [[ "${INIT_QUIET}" != "1" ]] && echo "custom APP_UID not defined, using default uid=1001"
    fi

    # set GID for docker group
    if [[ "${DOCKER_GID}" -ne "999" ]]; then
        [[ "${INIT_QUIET}" != "1" ]] && echo "set custom DOCKER_GID=${DOCKER_GID}"
        # check if another group already uses this GID
        existing_group=$(getent group "${DOCKER_GID}" | cut -d: -f1)
        if [[ -n "${existing_group}" && "${existing_group}" != "docker" ]]; then
            # reuse existing group - add app to it for socket access
            [[ "${INIT_QUIET}" != "1" ]] && echo "GID ${DOCKER_GID} used by '${existing_group}', adding app to it"
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
        [[ "${INIT_QUIET}" != "1" ]] && echo "custom DOCKER_GID not defined, using default gid=999"
    fi

    if ! chown -R app:app /srv; then
        echo "error: failed to chown /srv to app:app, the app user may not be able to write there"
    fi
    if [[ "${SKIP_HOME_CHOWN}" != "1" ]]; then
        if ! chown -R app:app /home/app; then
            echo "error: failed to chown /home/app to app:app, set SKIP_HOME_CHOWN=1 to skip this step for read-only mounts"
        fi
    fi
fi

if [[ -f "/srv/init.sh" ]]; then
    [[ "${INIT_QUIET}" != "1" ]] && echo "execute /srv/init.sh"
    if ! chmod +x /srv/init.sh; then
        echo "error: failed to make /srv/init.sh executable"
    fi
    if ! /srv/init.sh; then
        echo "/srv/init.sh failed"
        exit 1
    fi
fi

[[ "${INIT_QUIET}" != "1" ]] && echo execute "$@"
if [[ ${uid} -eq 0 ]]; then
    exec su-exec app "$@"
else
    exec "$@"
fi
