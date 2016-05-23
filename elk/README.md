Run the containers:

```
$ docker-compose up
```

and pipe some logs into logstash

```
$ java -jar target/*.jar | nc localhost 5000
```

Kibana runs on port 5601 (http://localhost:5601).

Example vanilla Spring Boot log:

```
2016-03-01 14:26:09.749  INFO 9063 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/metrics/field-value-counters],methods=[GET]}" onto public org.springframework.hateoas.PagedResources<? extends org.springframework.cloud.dataflow.rest.resource.MetricResource> org.springframework.cloud.dataflow.admin.controller.FieldValueCounterController.list(org.springframework.data.web.PagedResourcesAssembler<java.lang.String>)
```

Example matching logstash pattern:

```
%{TIMESTAMP_ISO8601:timestamp}\s+%{LOGLEVEL:severity}\s+%{DATA:pid}---\s+\[%{DATA:thread}\]\s+%{DATA:class}\s+:\s+%{GREEDYDATA:rest}
```

Add Sleuth:

```
%{TIMESTAMP_ISO8601:timestamp}\s+%{LOGLEVEL:severity}\s+\[%{DATA:service},%{DATA:trace},%{DATA:span},%{DATA:exportable}\]\s+%{DATA:pid}---\s+\[%{DATA:thread}\]\s+%{DATA:class}\s+:\s+%{GREEDYDATA:rest}
```

From a Cloud Foundry app into logstash:

```
$ cf logs voter-module | nc localhost 5000
```

Example log from cf with Sleuth:

```
2015-12-22T15:54:57.19+0000 [APP/0] OUT 2015-12-22 15:54:57.199 DEBUG [service,02bec129fad4d7e,99a76311a8eb222,false] 22 --- [nio-8080-exec-6] o.s.integration.channel.DirectChannel : postSend (sent=true) on channel 'output', message: GenericMessage [payload={"election":0,"candidate":0,"score":1}, headers={X-Span-Id=99a76311-b3de-4d77-bfe8-146f5a8eb222, X-Span-Name=http/votes, id=31fe6f08-d5e5-7c30-0aba-b2fec41ff779, contentType=application/json, X-Trace-Id=02bec129-d7b9-496e-ad94-75c0dfad4d7e, timestamp=1450799697196}]
```

Example matching logstash pattern:

```
(?m)OUT\s+%{TIMESTAMP_ISO8601:timestamp}\s+%{LOGLEVEL:severity}\s+\[%{DATA:service},%{DATA:trace},%{DATA:span},%{DATA:exportable}\]\s+%{DATA:pid}---\s+\[%{DATA:thread}\]\s+%{DATA:class}\s+:\s+%{GREEDYDATA:rest}
```

This is really useful: http://grokdebug.herokuapp.com/

