ARG JDK_VERSION=8

FROM azul/zulu-openjdk-alpine:${JDK_VERSION}
ARG PUID=1001
ARG PGID=1001

VOLUME [ "/tmp" ]

ENV PROG_OPTS="" \
    JAVA_OPTS="" \
    SERVER_HOSTNAME="localhost" \
    SERVER_PORT="8080" \
    JARFILE_APP_NAME="app.jar" 


ENV PATH="${JAVA_HOME}/bin:${PATH}"

COPY entrypoint.sh entrypoint.sh

#VUNERABILITY_ID:CVE-2020-28928 CVE-2020-1971 ...
RUN apk update && apk upgrade --available && sync

RUN addgroup -g ${PGID} springboot && \
    adduser -D -u ${PUID} -G springboot springboot

RUN chmod 744 /entrypoint.sh && chown springboot: /entrypoint.sh

RUN chown -R springboot: $JAVA_HOME

HEALTHCHECK --interval=15s --timeout=15s --start-period=40s \
 CMD wget --quiet --tries=3 --spider http://${SERVER_HOSTNAME}:${SERVER_PORT}/actuator/health || exit

ENTRYPOINT  [ "./entrypoint.sh" ]

EXPOSE ${SERVER_PORT}

