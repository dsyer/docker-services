Docker container for a reverse proxy routing to 2 backends based on a cookie or header.

Requests go to the first service listed by default, and can be sent to other services by adding an HTTP header `X-Server-Select` equal to the service name. Routing by a cookie is also supported:

```
$ curl localhost:8080 -H "Cookie: backend=blue"
Blue
$ curl localhost:8080 -H "Cookie: backend=green"
Green
$ curl localhost:8080
Green
```

The responses have headers that recor the routing decision:

```
$ curl -v localhost:8080 -H "Cookie: backend=blue"
...
< X-Server: blue
< X-Route: cookie
...
```

In a browser there is an endpoint you can visit `/choose/{route}` to set the cookie.
