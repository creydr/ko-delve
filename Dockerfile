FROM golang:1.21 as dlv-build

WORKDIR /go
RUN CGO_ENABLED=0 GOFLAGS= go install github.com/go-delve/delve/cmd/dlv@latest

FROM gcr.io/distroless/base:debug

COPY --from=dlv-build /go/bin/dlv /usr/bin/
# /bin/sh is not supported in distroless debug -> use mkdir directly from /busybox folder
RUN ["/busybox/mkdir", "/ko-app"]
WORKDIR /ko-app
USER 65534

ENTRYPOINT ["/usr/bin/dlv", "exec", "--listen=:40000", "--headless=true", "--log=true", "--accept-multiclient", "--api-version=2", "/ko-app/$(ls /ko-app/)"]
