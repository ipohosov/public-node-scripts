#!/bin/bash

mkdir lamina1
cd lamina1

wget https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/lamina1/Dockerfile
wget https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/lamina1/docker-compose.yaml

PUBLIC_IP=$(wget -qO- http://ipecho.net/plain | xargs echo)

echo "$PUBLIC_IP"

wget https://lamina1.github.io/lamina1/lamina1.latest.ubuntu-latest.tar.gz &&  tar xvf lamina1.latest.ubuntu-latest.tar.gz && rm -rf lamina1.latest.ubuntu-latest.tar.gz

docker-compose up -d lamina1