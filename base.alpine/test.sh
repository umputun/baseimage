#!/bin/bash
# smoke test for the app image init script, pass the image name as the first argument

image="${1:-umputun/baseimage:app-latest}"
failed=0
tmpdir=$(mktemp -d)
trap 'rm -rf "${tmpdir}"' EXIT

expect_out() { # name, expected substring, actual output
    if [[ "$3" == *"$2"* ]]; then echo "ok   - $1"; else
        echo "FAIL - $1: '$2' not found in:"
        printf '       %s\n' "$3"
        failed=1
    fi
}

expect_no_out() { # name, unexpected substring, actual output
    if [[ "$3" != *"$2"* ]]; then echo "ok   - $1"; else
        echo "FAIL - $1: '$2' unexpectedly present in:"
        printf '       %s\n' "$3"
        failed=1
    fi
}

expect_eq() { # name, expected output, actual output
    if [[ "$3" == "$2" ]]; then echo "ok   - $1"; else
        echo "FAIL - $1: expected '$2', got '$3'"
        failed=1
    fi
}

expect_code() { # name, expected code, actual code
    if [[ "$3" == "$2" ]]; then echo "ok   - $1"; else
        echo "FAIL - $1: expected exit $2, got $3"
        failed=1
    fi
}

# create root-owned files in the directories init.sh is expected to chown, then run init.sh,
# prints the owner of the /srv file on the first line and of the /home/app file on the second.
# files created in /home/app get the app group, hence the explicit chown
chown_probe() { # extra docker run arguments
    docker run --rm -e INIT_QUIET=1 "$@" --entrypoint /bin/sh "${image}" -c \
        'touch /srv/root-file /home/app/root-file && chown root:root /srv/root-file /home/app/root-file && exec /init.sh stat -c %U:%G /srv/root-file /home/app/root-file' 2>&1
}

expect_out "runs as app user" "uid=1001(app) gid=1001(app)" \
    "$(docker run --rm "${image}" id 2>&1)"

nonroot_out=$(docker run --rm -e INIT_QUIET=1 --user 1001 "${image}" id -u 2>&1)
nonroot_code=$?
expect_code "starts as non-root user" "0" "${nonroot_code}"
expect_eq "runs the command as non-root user" "1001" "${nonroot_out}"

expect_eq "applies TIME_ZONE" "JST" \
    "$(docker run --rm -e INIT_QUIET=1 -e TIME_ZONE=Asia/Tokyo "${image}" date +%Z 2>&1)"

expect_eq "records TIME_ZONE in /etc/timezone" "Asia/Tokyo" \
    "$(docker run --rm -e INIT_QUIET=1 -e TIME_ZONE=Asia/Tokyo "${image}" cat /etc/timezone 2>&1)"

expect_out "applies APP_UID" "uid=2000(app) gid=2000(app)" \
    "$(docker run --rm -e APP_UID=2000 "${image}" id 2>&1)"

expect_out "applies DOCKER_GID" "1500(docker)" \
    "$(docker run --rm -e DOCKER_GID=1500 "${image}" id 2>&1)"

expect_out "joins the group already holding DOCKER_GID" "998(ping)" \
    "$(docker run --rm -e DOCKER_GID=998 "${image}" id 2>&1)"

owners=$(chown_probe)
expect_eq "chowns /srv to app" "app:app" "$(sed -n 1p <<<"${owners}")"
expect_eq "chowns /home/app to app" "app:app" "$(sed -n 2p <<<"${owners}")"

owners=$(chown_probe -e SKIP_HOME_CHOWN=1)
expect_eq "SKIP_HOME_CHOWN still chowns /srv" "app:app" "$(sed -n 1p <<<"${owners}")"
expect_eq "SKIP_HOME_CHOWN leaves /home/app alone" "root:root" "$(sed -n 2p <<<"${owners}")"

printf '#!/bin/sh\necho "srv init ran"\n' >"${tmpdir}/init-ok.sh"
expect_out "runs /srv/init.sh" "srv init ran" \
    "$(docker run --rm -v "${tmpdir}/init-ok.sh:/srv/init.sh" "${image}" id 2>&1)"

printf '#!/bin/sh\nexit 3\n' >"${tmpdir}/init-fail.sh"
docker run --rm -v "${tmpdir}/init-fail.sh:/srv/init.sh" "${image}" id >/dev/null 2>&1
expect_code "stops when /srv/init.sh fails" "1" "$?"

quiet_out=$(docker run --rm -e INIT_QUIET=1 "${image}" id 2>&1)
expect_no_out "INIT_QUIET suppresses informational output" "init container" "${quiet_out}"
expect_out "INIT_QUIET still runs the command" "uid=1001(app)" "${quiet_out}"

bad_tz=$(docker run --rm -e TIME_ZONE=Nope/Nope "${image}" id 2>&1)
expect_out "reports an invalid TIME_ZONE" "error:" "${bad_tz}"
expect_out "starts anyway with an invalid TIME_ZONE" "uid=1001(app)" "${bad_tz}"

echo
if [[ ${failed} -eq 0 ]]; then echo "all checks passed"; else echo "some checks failed"; fi
exit ${failed}
