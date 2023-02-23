#!/bin/bash

mkdir lamina1

cd lamina1

wget https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/lamina1/Dockerfile

IP_ADDRESS=$(wget -qO- http://ipecho.net/plain | xargs echo)

docker build --build-arg PUBLIC_IP="${IP_ADDRESS}" -t lamina1-node:latest .

docker run -d --restart unless-stopped \
              --name lamina1-node-testnet \
              --mount source=lamina1-testnet-data,target=/data \
              lamina1-node:latest --config-file configs/testnet/default.json --data-dir /data
