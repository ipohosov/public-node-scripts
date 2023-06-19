function replace_bootstraps {
	config_path="$HOME/massa/massa-node/base_config/config.toml"
	bootstrap_list=`wget -qO- https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa/bootstrap_list.txt | shuf -n50 | awk '{ print "        "$0"," }'`
	len=`wc -l < "$config_path"`
	start=`grep -n bootstrap_list "$config_path" | cut -d: -f1`
	end=`grep -n "force the bootstrap protocol to use" "$config_path" | cut -d: -f1`
	end=$((end-1))
	first_part=`sed "${start},${len}d" "$config_path"`
	second_part="
    bootstrap_list = [
${bootstrap_list}
    ]
"
	third_part=`sed "1,${end}d" "$config_path"`
	echo "${first_part}${second_part}${third_part}" > "$config_path"
  sudo systemctl restart massa
}

replace_bootstraps