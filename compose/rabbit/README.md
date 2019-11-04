== Testing STOMP

```
$ docker-compose up stomp
$ nc localhost 61613
CONNECT


^@
CONNECTED
session:session-1tQu9gpqUadfHCdKu4A6hw
heart-beat:0,0
server:RabbitMQ/3.5.1
version:1.0

DISCONNECT


^@
```
