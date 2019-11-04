FROM alpine as build
WORKDIR /workspace/app
COPY settings.xml .
RUN mkdir /root/.m2 && cp settings.xml /root/.m2
RUN mkdir target && echo {"foo":"bar"} > foo.json && echo foo > target/foo
VOLUME /root/.m2

FROM alpine as native
WORKDIR /workspace/app
COPY --from=build /workspace/app/target target
COPY --from=build /workspace/app/*.json ./
RUN ls && ls /root/.m2 && echo foo > target/demo && chmod +x target/demo

FROM alpine
WORKDIR /workspace/app
VOLUME /tmp
COPY --from=native /workspace/app/target/demo ./
