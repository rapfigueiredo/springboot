#!/bin/sh
set -e

exec java ${JAVA_OPTS} \
  -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap \
  -Djava.security.egd=file:/dev/./urandom \
  -jar ${JARFILE_APP_NAME} ${PROG_OPTS}
