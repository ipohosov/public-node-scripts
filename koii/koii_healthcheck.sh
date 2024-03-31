#! /bin/bash

function restart_koii() {
    echo -e "Restart koii ...................................\n"
    docker-compose -f "$HOME"/task-template/docker-compose.yaml restart
}

cd "$HOME" || exit

while true
do
        echo -e "Check koii task logs \n"
        if [ "$(docker ps -a | grep task_node | grep Exited)" -gt 0 ]; then
            restart_koii
        elif [ "$(docker logs --tail=30 task_node 2>&1 | grep -i "FATAL ERROR")" -gt 0 ]; then
            restart_koii
	    fi

        date=$(date +"%H:%M")
        echo "Last Update: ${date}"
        printf "Sleep 1 hour\n"
        sleep 1h
done