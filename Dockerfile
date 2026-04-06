FROM eclipse-temurin:17-jre-jammy

ARG JMETER_VERSION=5.6.3

ENV JMETER_HOME=/opt/apache-jmeter-${JMETER_VERSION}
ENV PATH="${JMETER_HOME}/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates tar \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /opt; \
    curl -fL --retry 5 --retry-delay 3 "https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz" -o /tmp/jmeter.tgz \
    || curl -fL --retry 5 --retry-delay 3 "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz" -o /tmp/jmeter.tgz; \
    tar -xzf /tmp/jmeter.tgz -C /opt; \
    rm -f /tmp/jmeter.tgz

WORKDIR /workspace

ENTRYPOINT ["jmeter"]
