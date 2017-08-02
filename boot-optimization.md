Before:

```
FROM frolvlad/alpine-oraclejdk8:slim
VOLUME /tmp
ADD target/gs-spring-boot-docker-0.1.0.jar app.jar
RUN sh -c 'touch /app.jar'
ENV JAVA_OPTS=""
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]
```

After:

```
FROM openjdk:8-jdk-alpine
VOLUME /tmp
COPY target/dependency/org /app/org
COPY target/dependency/BOOT-INF/lib /app/BOOT-INF/lib
COPY target/dependency/META-INF /app/META-INF
COPY target/dependency/BOOT-INF/classes /app/BOOT-INF/classes
ENV JAVA_OPTS=""
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -cp app -Djava.security.egd=file:/dev/./urandom org.springframework.boot.loader.JarLauncher" ]
```

Total image size:

```
$ docker images
REPOSITORY                       TAG                 IMAGE ID            CREATED              SIZE
springio/gs-spring-boot-docker   latest              9f32f28005b1        About a minute ago   116 MB
...
```

Layers:

```
$ docker history 9f32f28005b1
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
9f32f28005b1        40 seconds ago       /bin/sh -c #(nop)  ENTRYPOINT ["sh" "-c" "...   0B                  
ce194570289b        About a minute ago   /bin/sh -c #(nop)  ENV JAVA_OPTS=               0B                  
70eae1c9d52f        About a minute ago   /bin/sh -c #(nop) COPY dir:a520ff470215f49...   1.21kB              
79f144a062c9        About a minute ago   /bin/sh -c #(nop) COPY dir:d5c9651b5a20e12...   3.67kB              
2447c7451dc6        About a minute ago   /bin/sh -c #(nop) COPY dir:6a6a881628c4ecc...   14.4MB              
72dbfce8a4c6        About a minute ago   /bin/sh -c #(nop) COPY dir:09e0d83963b61ee...   166kB               
d4912fde9c7f        4 weeks ago          /bin/sh -c #(nop)  VOLUME [/tmp]                0B                  
478bf389b75b        4 weeks ago          /bin/sh -c set -x  && apk add --no-cache  ...   97.1MB              
<missing>           4 weeks ago          /bin/sh -c #(nop)  ENV JAVA_ALPINE_VERSION...   0B                  
<missing>           4 weeks ago          /bin/sh -c #(nop)  ENV JAVA_VERSION=8u131       0B                  
<missing>           4 weeks ago          /bin/sh -c #(nop)  ENV PATH=/usr/local/sbi...   0B                  
<missing>           4 weeks ago          /bin/sh -c #(nop)  ENV JAVA_HOME=/usr/lib/...   0B                  
<missing>           4 weeks ago          /bin/sh -c {   echo '#!/bin/sh';   echo 's...   87B                 
<missing>           4 weeks ago          /bin/sh -c #(nop)  ENV LANG=C.UTF-8             0B                  
<missing>           5 weeks ago          /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B                  
<missing>           5 weeks ago          /bin/sh -c #(nop) ADD file:4583e12bf5caec4...   3.97MB              
```

Note the "fixed" layers are about 14MB and the "variable" layer is 4.65KB.

We need to unpack the jar into `target/dependency`: 

```
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-dependency-plugin</artifactId>
  <executions>
    <execution>
      <id>unpack</id>
      <phase>package</phase>
      <goals>
        <goal>unpack</goal>
      </goals>
      <configuration>
        <artifactItems>
          <artifactItem>
            <groupId>${project.groupId}</groupId>
            <artifactId>${project.artifactId}</artifactId>
            <version>${project.version}</version>
          </artifactItem>
        </artifactItems>
      </configuration>
    </execution>
  </executions>
</plugin>
```

## (Old) Spring Boot 1.3

Before:

```
FROM java:8
VOLUME /tmp
ADD gs-spring-boot-docker-0.1.0.jar app.jar
RUN bash -c 'touch /app.jar'
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
```

After:

```
FROM frolvlad/alpine-oraclejdk8
VOLUME /tmp
COPY fixed /app/
COPY variable /app/
RUN sh -c 'touch /app'
WORKDIR /app
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-cp", ".:lib/*","org.springframework.boot.loader.JarLauncher"]
```

```
$ docker images
REPOSITORY                       TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
springio/gs-spring-boot-docker   latest              9b75e1e008c3        8 minutes ago       184.1 MB
```

Layer sizes:

```
$ docker history 9b75e1e008c3
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
d82ecf54e6cd        5 minutes ago       /bin/sh -c #(nop) CMD ["/bin/sh" "-c" "sh"]     0 B                 
284b8555a420        5 minutes ago       /bin/sh -c #(nop) WORKDIR /app                  0 B                 
7558e73fae37        5 minutes ago       /bin/sh -c sh -c 'touch /app'                   0 B                 
d1d1c6343f1e        5 minutes ago       /bin/sh -c #(nop) COPY dir:909fcaa7743eaeba28   4.728 kB            
4b2960882577        5 minutes ago       /bin/sh -c #(nop) COPY dir:0c09189d1e407fc913   13.47 MB            
2a50ee218888        2 hours ago         /bin/sh -c #(nop) VOLUME [/tmp]                 0 B                 
f51430baaea4        17 hours ago        /bin/sh -c apk add --no-cache --virtual=build   159.1 MB            
a2ae998fec98        17 hours ago        /bin/sh -c #(nop) ENV JAVA_VERSION=8 JAVA_UPD   0 B                 
af14a1c68bee        18 hours ago        /bin/sh -c apk add --no-cache --virtual=build   6.745 MB            
2314ad3eeb90        2 weeks ago         /bin/sh -c #(nop) ADD file:0fc0a5ec098241ab15   4.794 MB   
```

Note the "fixed" layer is 13.47MB and the "variable" layer is 4.72KB.

```xml
<plugin>
  <groupId>com.spotify</groupId>
  <artifactId>docker-maven-plugin</artifactId>
  <version>0.2.3</version>
  <configuration>
    <imageName>${docker.image.prefix}/${project.artifactId}</imageName>
    <dockerDirectory>src/main/docker</dockerDirectory>
    <resources>
      <resource>
        <targetPath>/fixed</targetPath>
        <directory>${project.build.directory}/dependency</directory>
        <includes>
           <include>lib/**</include>
           <include>org/**</include>
        </includes>
      </resource>
      <resource>
        <targetPath>/variable</targetPath>
        <directory>${project.build.directory}/dependency</directory>
        <excludes>
           <exclude>lib/**</exclude>
           <exclude>org/**</exclude>
        </excludes>
      </resource>
    </resources>
  </configuration>
</plugin>
```

