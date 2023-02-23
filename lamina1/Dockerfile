FROM ubuntu:22.04

## Adapted from Ubuntu instructions here: 
## https://docs.lamina1.network/docs/userguide/#running-a-lamina1-node

ENV LAMINA1_BINARY=https://lamina1.github.io/lamina1/lamina1.latest.ubuntu-latest.tar.gz
ENV LAMINA1_CONFIGS4=https://lamina1.github.io/lamina1/config.testnet4.tar
ENV DATA_DIR /data
ENV LAMINA1_DIR /lamina1
ARG PUBLIC_IP

RUN groupadd -g 2000 -r node \
  && useradd -u 1001 -r -m -g node node \
  && mkdir -p "${DATA_DIR}/db" \
  && mkdir -p "${LAMINA1_DIR}" \
  && chown -R node:node "${DATA_DIR}" \
  && chown -R node:node "${LAMINA1_DIR}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    netcat \
    jq \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR ${LAMINA1_DIR}
RUN curl ${LAMINA1_BINARY} | tar xzf - --strip-components=1
RUN curl ${LAMINA1_CONFIGS4} | tar xf -

USER "node"
ENTRYPOINT ["./lamina1-node --config-file configs/testnet4/default.json --public-ip=$PUBLIC_IP"]


# Expose default ports: 9650(API) and 9671(P2P)
EXPOSE 9671 9650