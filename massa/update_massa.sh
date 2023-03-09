#!/bin/bash

function get_env {
	source $HOME/.profile
	source $HOME/.cargo/env
}

function massa_backup {
	cd $HOME
	if [ ! -d $HOME/massa_backup20/ ]; then
		mkdir -p $HOME/massa_backup20
		cp $HOME/massa/massa-node/config/node_privkey.key $HOME/massa_backup20/
		cp $HOME/massa/massa-client/wallet.dat $HOME/massa_backup20/
	fi
	if [ ! -e $HOME/massa_backup20.tar.gz ]; then
		tar cvzf massa_backup.tar20.gz massa_backup20
	fi
}

function delete {
  sudo systemctl stop massa
  rm -rf massa_TEST.1*
  rm -rf $HOME/massa
}

function install {
  wget https://github.com/massalabs/massa/releases/download/TEST.20.1/massa_TEST.20.1_release_linux.tar.gz
  tar zxvf massa_TEST.20.1_release_linux.tar.gz -C $HOME/
}

function routable_ip {
  sed -i 's/.*routable_ip/# \0/' "$HOME/massa/massa-node/base_config/config.toml"
  sed -i "/\[network\]/a routable_ip=\"$(curl -s ifconfig.me)\"" "$HOME/massa/massa-node/base_config/config.toml"
}


get_env
massa_backup
delete
install
routable_ip


sudo systemctl start massa