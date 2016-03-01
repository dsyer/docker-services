A collection of docker-compose.yml files useful for running data services (e.g. redis, rabbit, mongo) locally.

To run in a VM or a remote platform you can use `docker-machine` and an ssh tunnel to map the ports to localhost. E.g. for redis

```
$ machine=splash # arbitrary name
$ docker create $machine # add options for --driver
$ eval "$(docker-machine env $machine)"
$ (cd redis; docker-compose up)
$ docker-machine ssh $machine -- -L 6379:localhost:6379
# in another terminal:
$ redis-cli
128.0.0.1:6379>
```

> TIP: to break out of an ssh tunnel use `Enter ~ .` (key sequence).

> NOTE: the tunnel is `$remoteport:localhost:$localport` (the opposite order to `docker -p`).

To create the machine on EC2 use `--driver amazonec2` with 

```
AWS_DEFAULT_REGION=eu-west-1
AWS_SECRET_ACCESS_KEY=...
AWS_ACCESS_KEY_ID=...
AWS_VPC_ID=...
```
where the VPC id can be copied from [AWS Console](https://console.aws.amazon.com) (it has to be in the region specified and the 'a' availability zone by default).

> NOTE: you can automate the tunnel creation with a script, e.g. `docker-tunnel $machine 6379 3303`.
