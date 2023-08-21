#! /bin/bash

cd "$HOME" || exit

CONTAINER_ID=$(docker ps -aqf "name=evvv")
LINES=20

while true
do
      echo -e "Check elixir validator logs \n"
      if docker logs --tail $LINES $CONTAINER_ID | grep -q "Connection closed error"; then
          echo "Connection closed error found in logs. Restarting container..."
          docker restart $CONTAINER_ID
          echo "Container restarted."
      else
          echo "No connection closed errors found in logs."
      fi

      date=$(date +"%H:%M")
      echo "Last Update: ${date}"
      printf "Sleep 1 hour\n"
      sleep 15m
done