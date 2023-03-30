FROM registry.access.redhat.com/ubi9/openjdk-17:1.14-2 as builder

RUN mkdir app
WORKDIR app
COPY --chown=default . .
RUN ./gradlew shadowJar

FROM registry.access.redhat.com/ubi9/openjdk-17-runtime:1.14-2

COPY --from=builder --chown=default /home/default/app/build/libs/*-all.jar /deployments
