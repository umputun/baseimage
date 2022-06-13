#!/bin/sh

# this is a stub server, for ping requests. Listening on port 8080.
info=$1

echo "ping-pong server, listening on port 8080 ${info}"

echo "HTTP/1.1 200 OK" > /tmp/pong.http
echo "Content-Type: text/html; charset=UTF-8" >> /tmp/pong.http
echo "Server: ${info}" >> /tmp/pong.http
echo >> /tmp/pong.http
echo "pong"  >> /tmp/pong.http
cat /tmp/pong.http

while true; do cat /tmp/pong.http | nc -l -p 8080; done
