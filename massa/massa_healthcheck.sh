#! /bin/bash

cd "$HOME" || exit
while true
do
    printf "Check massa logs \n"
    if [ "$(journalctl -n 50 -u massa --no-pager | grep -c "error")" -gt 5 ]; then
        printf "Restart massa ...................................\n"
        sudo systemctl restart massa
    fi
    date=$(date +"%H:%M")
    echo "Last Update: ${date}"
    printf "Sleep 5 minutes\n"
    sleep 5m
done