#!/bin/sh

tail -qF /var/log/squid/access.log /var/log/squid/cache.log 2> /dev/null &

exec "$@"
