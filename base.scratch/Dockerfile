FROM ghcr.io/umputun/baseimage/app:latest AS prep

RUN apk add -u tzdata ca-certificates build-base gcc

RUN \
    echo "#include <unistd.h>" > /tmp/pause.c && \
    echo "#include <stdio.h>" >> /tmp/pause.c && \
    echo 'int main(){ printf("nop wait...\n"); pause(); }' >> /tmp/pause.c && \
    gcc -static -O3 /tmp/pause.c -o /tmp/nop && \
    ls -la /tmp/nop

# generate minimal passwd and group with only root and app entries
RUN echo "root:x:0:0:root:/root:/sbin/nologin" > /tmp/passwd && \
    echo "app:x:1001:1001:app:/home/app:/sbin/nologin" >> /tmp/passwd

RUN echo "root:x:0:" > /tmp/group && \
    echo "app:x:1001:" >> /tmp/group

FROM scratch

LABEL org.opencontainers.image.authors="Umputun <umputun@gmail.com>"
# enables automatic changelog generation by tools like Dependabot
LABEL org.opencontainers.image.source="https://github.com/umputun/baseimage"

ENV TZ=America/Chicago
COPY --from=prep /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=prep /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=prep /tmp/passwd /etc/passwd
COPY --from=prep /tmp/group /etc/group
COPY --from=prep /tmp/nop /nop
ADD tmp.tar /

USER app
WORKDIR /srv


