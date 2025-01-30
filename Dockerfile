FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

ENV ARCH=amd64
ENV GO_VERSION=1.23.5

# Install dependencies
RUN apt update && apt clean && apt upgrade -y && useradd -m runner
RUN apt install make jq wget curl git libicu-dev gcc build-essential docker.io -y

# Install Golang
RUN mkdir -p /tempgo
RUN wget -P /tempgo "https://dl.google.com/go/go${GO_VERSION}.linux-${ARCH}.tar.gz"

RUN tar -C /usr/local -xzf "/tempgo/go${GO_VERSION}.linux-${ARCH}.tar.gz"
RUN rm "/tempgo/go${GO_VERSION}.linux-${ARCH}.tar.gz"

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Setup actions runner
RUN mkdir -p /actions-runner

COPY start.sh /actions-runner/start.sh

RUN chown -R runner:runner /actions-runner
USER runner

WORKDIR /actions-runner

RUN curl -o actions-runner-linux-${ARCH}-2.321.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-linux-${ARCH}-2.321.0.tar.gz

RUN tar xzf ./actions-runner-linux-${ARCH}-2.321.0.tar.gz

ENTRYPOINT ["/actions-runner/start.sh"]
