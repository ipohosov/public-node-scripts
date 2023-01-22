#!/bin/bash
#Thank's for ipohosov. Donates - TZ7pxizxodsy8J52D5FZzQFp3X5DSpyB1X


cd $HOME
while true
do
        printf "Check massa logs \n"
        if [ $(journalctl -n 20 -u massa --no-pager | grep -c "final_state hash at slot") -lt 1 ]; then
            printf "Restart massa ...................................\n"
            sudo systemctl restart massa
	    fi

        date=$(date +"%H:%M")
        echo "Last Update: ${date}"
        printf "Sleep 15 minutes\n"
        sleep 15m
done