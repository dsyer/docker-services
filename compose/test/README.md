```
$ docker build -t demo .
$ docker run --privileged -i -t demo --storage-driver=bitrfs
