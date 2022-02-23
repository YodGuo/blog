FROM adoptopenjdk:11-jre-hotspot as builder

WORKDIR application

ARG JAR_FILE=build/libs/*.jar

RUN curl -L https://github.com/halo-dev/halo/releases/download/v1.4.17/halo-1.4.17.jar --output application.jar \
    && java -Djarmode=layertools -jar application.jar extract

################################

FROM adoptopenjdk:11-jre-hotspot

LABEL maintainer="Miacis Wang <miacis@111.com>"

WORKDIR application

COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./

# JVM_XMS and JVM_XMX configs deprecated for removal in halov1.4.4
ENV JVM_XMS="256m" \
    JVM_XMX="256m" \
    JVM_OPTS="-Xmx256m -Xms256m" \
    TZ=Asia/Shanghai

RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

ENTRYPOINT [ "/bin/sh", "/app/docker-entrypoint.sh" ]