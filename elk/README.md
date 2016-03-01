Run the containers:

```
$ docker-compose up
```

and pipe some logs from a Cloud Foundry app into logstash:

```
$ cf logs voter-module | nc localhost 5000
```

This is really useful: http://grokdebug.herokuapp.com/

Example log from cf logs:

```
2015-12-22T15:54:57.19+0000 [APP/0] OUT 2015-12-22 15:54:57.199 DEBUG [trace=02bec129-d7b9-496e-ad94-75c0dfad4d7e,span=99a76311-b3de-4d77-bfe8-146f5a8eb222] 22 --- [nio-8080-exec-6] o.s.integration.channel.DirectChannel : postSend (sent=true) on channel 'output', message: GenericMessage [payload={"election":0,"candidate":0,"score":1}, headers={X-Span-Id=99a76311-b3de-4d77-bfe8-146f5a8eb222, X-Span-Name=http/votes, id=31fe6f08-d5e5-7c30-0aba-b2fec41ff779, contentType=application/json, X-Trace-Id=02bec129-d7b9-496e-ad94-75c0dfad4d7e, timestamp=1450799697196}]
```
