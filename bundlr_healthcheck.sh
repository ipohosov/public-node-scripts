#!/bin/bash

cd $HOME
while true
do
        printf "Check bundlr validator logs \n"
        if [ $(docker logs --tail=20 validator | grep -c "Connection reset by peer") -gt 0 ]; then
            printf "Restart bundlr ...................................\n"
            docker-compose -f $HOME/bundlr/validator-rust/docker-compose.yml restart
	    fi

        date=$(date +"%H:%M")
        echo "Last Update: ${date}"
        printf "Sleep 1 hour\n"
        sleep 1h
done