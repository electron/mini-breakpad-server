SOURCE_VERSION=${1:-master}

#echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
docker push premiereglobal/mini-breakpad-server:${SOURCE_VERSION}
