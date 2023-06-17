#!/bin/bash

function get_env {
	source $HOME/.profile
	source $HOME/.cargo/env
}

function delete {
  sudo systemctl stop massa
  rm -rf massa_TEST.*
  rm -rf $HOME/massa
}

function install {
  wget https://github.com/massalabs/massa/releases/download/TEST.23.2/massa_TEST.23.2_release_linux.tar.gz
  tar zxvf massa_TEST.23.2_release_linux.tar.gz -C $HOME/
  rm -rf massa_TEST.*

function configure {
	# Get IP and replace routable ip
	echo "Get IP and replace routable ip"
	ifconfig | grep -q 'inet6'
	if [[ $? -eq 0 ]]; then
		echo "Get IPv6"
		server_ip=$(ifconfig | grep inet6 | grep global | awk '{print $2}')
	else
		echo "Get IPv4"
		server_ip=$(hostname -I | awk '{print $1}')
	fi

	config_path="$HOME/massa/massa-node/base_config/config.toml"
	sed -i 's/.*routable_ip/# \0/' $config_path
	sed -i "/\[network\]/a routable_ip=\"$server_ip\"" $config_path

	# Remove bootstrap_whitelist.json
	echo "Remove bootstrap_whitelist.json"
	rm -rf /root/massa/massa-node/base_config/bootstrap_whitelist.json

	# Update retry_delay
	echo "Update retry_delay"
	sed -i -e "s%retry_delay *=.*%retry_delay = 10000%; " "$config_path"
}


get_env
delete
install
configure



sudo systemctl start massa