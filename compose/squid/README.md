Docker container for a forward proxy to the internet.

For some reason `docker-compose` doesn't work if you use the `build` directive, but it does work with a named image. So you can

```
$ docker build -t dsyer/squid .
$ docker-compose up
```

Then set env vars `https_proxy=http://localhost:3128` (or `git config
http.proxy http://localhost:3128` for git only), or for Java processes
use `-Dhttps.proxyHost=localhost`, `-Dhttps.proxyPort=3128`. If you
curl a remote site or clone a remote repo the traffic will go through
squid and you will see the access logs on stdout of the docker
container.
