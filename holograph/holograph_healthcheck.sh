#! /bin/bash

cd "$HOME" || exit
while true
do
    printf "Check holograph logs \n"
    if [ "$(journalctl -n 100 -u holographd --no-pager | grep -c "Ineffective mark-compacts near heap limit Allocation failed - JavaScript heap out of memory")" -gt 5 ]; then
        printf "Restart holograph ...................................\n"
        sudo systemctl restart holographd
    fi
    date=$(date +"%H:%M")
    echo "Last Update: ${date}"
    printf "Sleep 15 minutes\n"
    sleep 15m
done