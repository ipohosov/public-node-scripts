#! /bin/bash

function get_nodes_count() {
    nodes=$(curl -s -X POST   -H "Rusk-Version: 0.7"   -H "Content-Type: application/json"   -d '{"topic": "alive_nodes", "data": " 100"}'   http://127.0.0.1:8980/02/Chain | jq -r 'length')
    echo "${nodes}"
}

cd "$HOME" || exit
source .profile
sudo apt install jq -y

while true
do
  date=$(date +"%H:%M")
  echo "Last Update: ${date}"
  printf "Check shardeum node status \n"
  nodes=$(get_nodes_count)
  printf "Online nodes: ${nodes}\n"

  if [[ "${nodes}" -gt "0" ]]; then
      printf "Everything is ok\n"
      sleep 15m
  else
      printf "Restart rusk dusk Elon mask"
      echo "Last Update: ${date}"
      docker compose restart -f /root/rusk/docker-compose.yml
      sleep 15m
  fi
done