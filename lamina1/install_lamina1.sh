#!/bin/bash

mkdir lamina1

cd lamina1

wget https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/lamina1/Dockerfile

docker build -f docker/Dockerfile -t lamina1-node:latest .

docker run -d --restart unless-stopped \
              --name lamina1-node-testnet \
              --mount source=lamina1-testnet-data,target=/data \
              lamina1-node:latest --config-file configs/testnet/default.json --data-dir /data
