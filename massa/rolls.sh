#!/bin/bash

source $HOME/.profile
cd $HOME/massa/massa-client
massa_wallet_address=$(./massa-client --pwd $massa_pass wallet_info | grep Address | awk '{ print $2 }')
while true
do
        balance=$(./massa-client --pwd $massa_pass wallet_info | grep "Rolls" | awk '{ print $3 }' | sed 's/final=//;s/,//')
        int_balance=${balance%%.*}
        if [ $int_balance -lt "1" ]; then
                echo "Less than 1 Final Roll"
                resp=$(./massa-client --pwd $massa_pass buy_rolls $massa_wallet_address 1 0)
                echo $resp
        fi
        date=$(date +"%H:%M")
        echo Last Update: ${date}
        sleep 2m
        printf "\n"
done