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
$ docker history d82ecf54e6cd
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

and 

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
