FROM registry.access.redhat.com/ubi9/openjdk-17:1.14-2

RUN mkdir app
WORKDIR app
COPY --chown=default . .
RUN ./gradlew shadowJar
RUN cp build/libs/webcrawler*-all.jar /deployments
