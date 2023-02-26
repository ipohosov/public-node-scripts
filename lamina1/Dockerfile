FROM ubuntu:22.04

ARG PUBLIC_IP
COPY /lamina1 /root/lamina1
WORKDIR /root/lamina1

RUN mkdir data

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    netcat \
    jq \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "$PUBLIC_IP"

# ENTRYPOINT ["./lamina1-node --config-file configs/testnet4/default.json --public-ip=$PUBLIC_IP"]
ENTRYPOINT ["./lamina1-node --config-file configs/testnet4/default.json"]


# Expose default ports: 9650(API) and 9671(P2P)
EXPOSE 9671 9650