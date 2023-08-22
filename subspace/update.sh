#!/bin/bash


function get_vars {
  export CHAIN="gemini-3f"
  export RELEASE="gemini-3f-2023-aug-21"
  export SUBSPACE_NODENAME=$(cat $HOME/subspace_docker/docker-compose.yml | grep "\-\-name" | awk -F\" '{print $4}')
  export WALLET_ADDRESS=$(cat $HOME/subspace_docker/docker-compose.yml | grep "\-\-reward-address" | awk -F\" '{print $4}')
  export PLOT_SIZE=$(cat $HOME/subspace_docker/docker-compose.yml | grep "\-\-plot-size" | awk -F\" '{print $4}')
}

function delete_old {
  docker-compose -f $HOME/subspace_docker/docker-compose.yml down -v &>/dev/null
  docker volume rm subspace_docker_subspace-farmer subspace_docker_subspace-node &>/dev/null
}

function eof_docker_compose {
  mkdir -p $HOME/subspace_docker/
  sudo tee <<EOF >/dev/null $HOME/subspace_docker/docker-compose.yml
  version: "3.7"
  services:
    node:
      image: ghcr.io/subspace/node:$RELEASE
      volumes:
        - node-data:/var/subspace:rw
      ports:
        - "0.0.0.0:32333:30333"
        - "0.0.0.0:32433:30433"
      restart: unless-stopped
      command: [
        "--chain", "$CHAIN",
        "--base-path", "/var/subspace",
        "--execution", "wasm",
        "--blocks-pruning", "256",
        "--state-pruning", "archive",
        "--port", "30333",
        "--dsn-listen-on", "/ip4/0.0.0.0/tcp/30433",
        "--rpc-cors", "all",
        "--rpc-methods", "unsafe",
        "--rpc-external",
        "--no-private-ipv4",
        "--validator",
        "--name", "$SUBSPACE_NODENAME",
        "--telemetry-url", "wss://telemetry.subspace.network/submit 0",
        "--telemetry-url", "wss://telemetry.doubletop.io/submit 0",
        "--out-peers", "100"
      ]
      healthcheck:
        timeout: 5s
        interval: 30s
        retries: 5

    farmer:
      depends_on:
        - node
      image: ghcr.io/subspace/farmer:$RELEASE
      volumes:
        - farmer-data:/var/subspace:rw
      ports:
        - "0.0.0.0:32533:30533"
      restart: unless-stopped
      command: [
        "farm",
        "--node-rpc-url", "ws://node:9944",
        "--listen-on", "/ip4/0.0.0.0/tcp/30533",
        "--reward-address", "$WALLET_ADDRESS",
        "path=/var/subspace,size=100G"
      ]
  volumes:
    node-data:
    farmer-data:
EOF
}


function update_subspace {
  cd $HOME/subspace_docker/
  docker-compose down
  eof_docker_compose
  docker-compose pull
  docker-compose up -d
}


get_vars
delete_old
eof_docker_compose
update_subspace

echo -e "=== Обновление завершено ==="
cd $HOME