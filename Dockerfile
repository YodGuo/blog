FROM adoptopenjdk:11-jre-hotspot as builder

WORKDIR application

ARG JAR_FILE='build/libs/*.jar'
ARG HALO_VERSION='1.4.17'
ARG GITHUB_PROXY

RUN curl -L ${GITHUB_PROXY}https://github.com/halo-dev/halo/releases/download/v${HALO_VERSION}/halo-${HALO_VERSION}.jar --output application.jar \
    && java -Djarmode=layertools -jar application.jar extract

################################

FROM adoptopenjdk:11-jre-hotspot

LABEL maintainer="Miacis Wang <miacis@111.com>"

WORKDIR application

COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./
COPY ./docker-entrypoint.sh ./docker-entrypoint.sh

# JVM_XMS and JVM_XMX configs deprecated for removal in halov1.4.4
ENV JVM_XMS="256m"
ENV JVM_XMX="256m"
ENV JVM_OPTS="-Xmx256m -Xms256m"
ENV TZ='Asia/Shanghai'
ENV HALO_DATABASE='H2'

ENTRYPOINT [ "/bin/bash", "./docker-entrypoint.sh" ]