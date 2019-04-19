#!/bin/sh

VERSION=${1:-master}

# Build the binary in Docker and extract it from the container
docker build -t premiereglobal/mini-breakpad-server:${VERSION} ./
