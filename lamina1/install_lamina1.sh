#!/bin/bash

mkdir lamina1
cd lamina1

wget https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/lamina1/Dockerfile
wget https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/lamina1/Dockerfile.main
wget https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/lamina1/docker-compose.yaml

IP_ADDRESS=$(wget -qO- http://ipecho.net/plain | xargs echo)

wget https://lamina1.github.io/lamina1/lamina1.latest.ubuntu-latest.tar.gz &&  tar xvf lamina1.latest.ubuntu-latest.tar.gz && rm -rf lamina1.latest.ubuntu-latest.tar.gz
wget https://lamina1.github.io/lamina1/config.testnet.tar && tar xvf config.testnet.tar && rm -rf config.testnet.tar

if [ ! -d "/root/.lamina1" ]; then
  docker-compose up -d lamina1-first-start
  folder_path="/root/.lamina1"

  while [ ! -d "$folder_path" ]
  do
    echo "Waiting for $folder_path to appear..."
    sleep 1
  done

  echo "$folder_path has appeared!"
  docker rm -f lamina1-first-start
fi

rm -rf lamina1/configs/
mv configs/ lamina1/

docker-compose up -d lamina1-main
