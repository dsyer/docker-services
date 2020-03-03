FROM dsyer/demo as build

FROM openjdk:8-jdk-alpine as base
RUN apk update
RUN apk add linux-virt
RUN apk add openrc
RUN echo root:root | chpasswd

FROM base
VOLUME /tmp
WORKDIR /
COPY --from=build /app app
ENTRYPOINT ["sh", "-c", "java -noverify -XX:TieredStopAtLevel=1 -cp /app:/app/lib/*:${EXT_LIBS}/*   com.example.demo.DemoApplication ${0} ${@}"]