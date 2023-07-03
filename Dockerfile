FROM registry.access.redhat.com/ubi9/openjdk-17:1.15-1.1686736679 as builder

# Installs gradle dependencies
RUN mkdir app
WORKDIR app
COPY --chown=default gradle              gradle
COPY --chown=default build.gradle.kts    .
COPY --chown=default gradle.properties   .
COPY --chown=default gradlew             .
COPY --chown=default gradlew.bat         .
COPY --chown=default settings.gradle.kts .
RUN ./gradlew dependencies

## Builds the application
COPY --chown=default . .
RUN ./gradlew shadowJar

FROM registry.access.redhat.com/ubi9/openjdk-17-runtime:1.15-1

ENV HEADLESS=TRUE
ARG packages="chromium chromedriver"

# Installs the os dependencies (chromium and chromedriver)
USER root
RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
      && rpm -ivh https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-9.0-20.el9.noarch.rpm\
      && rpm -ivh https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-9.0-20.el9.noarch.rpm\
      && microdnf --setopt=install_weak_deps=0 --setopt=tsflags=nodocs install -y $packages \
      && microdnf clean all \
      && rpm -q $packages

# Copies the jar from the build container
USER default
COPY --from=builder --chown=default /home/default/app/build/libs/*-all.jar /deployments
