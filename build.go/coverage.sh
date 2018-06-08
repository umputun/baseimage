#!/bin/bash
# Generate test coverage statistics for Go packages.

set -e

workdir=.cover
profile="$workdir/cover.out"
mode=count

if [ "$#" -eq  "0" ] ; then
    app="app"
else
    app=$1
fi
echo "generate coverage for $app"

generate_cover_data() {
    rm -rf "$workdir"
    mkdir "$workdir"

    for pkg in "$@"; do
        f="$workdir/$(echo $pkg | tr / -).cover"
        go test -covermode="$mode" -coverprofile="$f" "$pkg"
    done

    echo "mode: $mode" >"$profile"
    grep -h -v "^mode:" "$workdir"/*.cover >>"$profile"
}

show_cover_report() {
    go tool cover -${1}="$profile"
}

generate_cover_data $(go list ./... | grep -v vendor | grep -v mock)
go tool cover -html="./${profile}" -o target/coverage.html
show_cover_report func
