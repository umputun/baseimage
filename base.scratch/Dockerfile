FROM ghcr.io/umputun/baseimage/app:lastest as prep

LABEL maintainer="Umputun <umputun@gmail.com>"

RUN apk add -u tzdata ca-certificates build-base gcc

RUN \
    echo "#include <unistd.h>" > /tmp/pause.c && \
    echo "#include <stdio.h>" >> /tmp/pause.c && \
    echo 'int main(){ printf("nop wait...\n"); pause(); }' >> /tmp/pause.c && \
    gcc -static -O3 /tmp/pause.c -o /tmp/nop && \
    ls -la /tmp/nop

FROM scratch
ENV TZ=America/Chicago
COPY --from=prep /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=prep /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=prep /etc/passwd /etc/passwd
COPY --from=prep /etc/group /etc/group
COPY --from=prep /tmp/nop /nop

USER app
WORKDIR /srv


