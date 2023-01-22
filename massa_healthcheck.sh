#!/bin/bash
#Thank's for ipohosov. Donates - TZ7pxizxodsy8J52D5FZzQFp3X5DSpyB1X


cd $HOME
while true
do
        printf "Check massa logs \n"
        if [ $(journalctl -n 20 -u massa --no-pager | grep -c "final_state hash at slot") -lt 1 ]; then
            printf "Stop massa ...................................\n"
            sudo systemctl stop massa
            printf "Wait 15 minutes\n"
            sleep 15m
            printf "Start massa ...................................\n"
            sudo systemctl start massa
	    fi

        date=$(date +"%H:%M")
        echo "Last Update: ${date}"
        printf "Sleep 15 minutes\n"
        sleep 15m
done