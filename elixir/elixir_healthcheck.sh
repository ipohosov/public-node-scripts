#! /bin/bash

function restart_elixir() {
    echo -e "Restart elixir ...................................\n"
    docker restart ev
}

cd "$HOME" || exit

while true
do
      echo -e "Check elixir validator logs \n"
      if [ "$(docker logs -f --tail=100 ev 2>&1 | grep -c "Connection closed error")" -gt 0 ]; then
          restart_elixir
	    fi

      date=$(date +"%H:%M")
      echo "Last Update: ${date}"
      printf "Sleep 1 hour\n"
      sleep 15m
done