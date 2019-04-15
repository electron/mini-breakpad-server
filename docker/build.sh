#!/bin/sh

VERSION=${1:-master}

# Directory to house our binaries
mkdir -p bin

# Build the binary in Docker and extract it from the container
docker build --build-arg GOOS=linux -t premiereglobal/mini-breakpad-server:${VERSION} ./

