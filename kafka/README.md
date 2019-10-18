```
$ fig up
```

Send a message:

```
$ curl localhost:8082/topics/input -H "Content-Type: application/vnd.kafka.json.v2+json" --data '{"records":[{"value":{"name": "testUser"}}]}'
```

Links:

* https://github.com/confluentinc/kafka-rest
