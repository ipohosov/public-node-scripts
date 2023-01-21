#!/bin/bash
#Thank's for https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa_healthcheck.sh


cd $HOME
while true
do
        printf "Check massa logs"
        if [ $(journalctl -n 5 -u massa --no-pager | grep -c "INFO massa_final_state::final_state: final_state hash at slot") < 1 ]; then
		    printf "Restart massa"
            printf "\n"
            systemctl restart massa
	    fi

        date=$(date +"%H:%M")
        printf Last Update: ${date}
        printf "Sleep 15 minutes"
        sleep 1m
        printf "\n"
done