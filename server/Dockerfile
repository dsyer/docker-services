FROM golang:alpine as build

WORKDIR /root

COPY . .

RUN CGO_ENABLED=0 go build -a -installsuffix cgo

from ubuntu:bionic

COPY --from=build /root/server .

ENTRYPOINT ["/server"]