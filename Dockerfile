FROM ubuntu:20.04 as builder

RUN set -ex; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    curl \
    openjdk-11-jdk-headless \
  ; \
  rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 -s /bin/bash besu
USER besu

ARG VERSION

RUN set -ex; \
  mkdir /home/besu/besu; \
  curl -L https://github.com/hyperledger/besu/archive/${VERSION}.tar.gz | tar -xz --strip-components=1 -C /home/besu/besu

RUN set -ex; \
  cd /home/besu/besu; \
  ./gradlew installDist


FROM ubuntu:20.04

RUN set -ex; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    curl \
    openjdk-11-jre-headless \
  ; \
  rm -rf /var/lib/apt/lists/*

COPY --from=builder /home/besu/besu/build/install/besu /opt/

RUN useradd -m -u 1000 -s /bin/bash besu
USER besu
WORKDIR /opt
ENTRYPOINT ["/opt/bin/besu"]
