FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt clean && apt upgrade -y && useradd -m runner
RUN apt install make jq wget curl git libicu-dev gcc build-essential docker.io -y

RUN mkdir -p /actions-runner

COPY start.sh /actions-runner/start.sh

WORKDIR /actions-runner

RUN curl -o actions-runner-linux-x64-2.321.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-linux-x64-2.321.0.tar.gz

RUN tar xzf ./actions-runner-linux-x64-2.321.0.tar.gz

USER runner

ENTRYPOINT ["/actions-runner/start.sh"]
