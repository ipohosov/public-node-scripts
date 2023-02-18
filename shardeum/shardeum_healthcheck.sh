#! /bin/bash

function login() {
    TOKEN=$(curl --location --insecure --request POST 'https://${IP_ADDRESS}:${SHARDEUM_DASHBOARD_PORT}/auth/login' \
    --header 'Content-Type: application/json' \
    --data-raw '{"password":"${SHARDEUM_DASHBOARD_PWD}"}')
    echo "${TOKEN}"
}


function get_status() {
    STATUS=$(docker exec -t shardeum-dashboard operator-cli status | grep state | awk '{ print $2 }')
    echo "${STATUS}"
}


function start_node() {
    TOKEN=${1}
    curl --location --request POST 'https://${IP_ADDRESS}:${SHARDEUM_DASHBOARD_PORT}/api/node/start' \
    --header 'Content-Type: application/json' \
    --header 'X-Api-Token: ${TOKEN}'
}

cd "$HOME" || exit
IP_ADDRESS=$(wget -qO- http://ipecho.net/plain | xargs echo)
while true
do
        printf "Check shardeum node status \n"
        NODE_STATUS=$(get_status)
        printf "Current status: ${NODE_STATUS}"
        sleep 5s
        if [[ "${NODE_STATUS}" == "stopped" ]]; then
            printf "Start shardeum node and wait 5 minutes"
            JWT_TOKEN=$(login)
            start_node "${JWT_TOKEN}"
            sleep 5m
        else
            date=$(date +"%H:%M")
            echo "Last Update: ${date}"
            printf "Sleep 15 minutes\n"
            sleep 15m
        fi
done