FROM docker:dind
ENV LANG C.UTF-8
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u131

RUN apk add --no-cache py-pip curl
RUN pip install docker-compose
RUN apk add --no-cache openjdk8

ADD run.sh /run.sh
ADD docker-compose.yml /docker-compose.yml

RUN mkdir /etc/docker && echo '{"debug":true}' > /etc/docker/daemon.json

CMD ["/bin/sh"]