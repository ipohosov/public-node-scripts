#! /bin/bash

cd "$HOME" || exit
while true
do
    printf "Check massa logs \n"
    if [ "$(journalctl -n 50 -u massa --no-pager | grep -c "final_state hash at slot")" -gt 0 ]; then
        printf "Restart massa ...................................\n"
        sudo systemctl restart massa
    fi
    date=$(date +"%H:%M")
    echo "Last Update: ${date}"
    printf "Sleep 15 minutes\n"
    sleep 15m
done