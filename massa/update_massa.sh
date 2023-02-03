#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function get_env {
	source $HOME/.profile
	source $HOME/.cargo/env
}

function massa_backup {
	cd $HOME
	if [ ! -d $HOME/massa_backup/ ]; then
		mkdir -p $HOME/massa_backup
		cp $HOME/massa/massa-node/config/node_privkey.key $HOME/massa_backup/
		cp $HOME/massa/massa-client/wallet.dat $HOME/massa_backup/
        cp $HOME/massa/massa-node/base_config/config.toml
	fi
}

function delete {
  sudo systemctl stop massa
  rm -rf $HOME/massa
}

function install {
  wget https://github.com/massalabs/massa/releases/download/TEST.19.1/massa_TEST.19.1_release_linux.tar.gz
  tar zxvf massa_TEST.19.1_release_linux.tar.gz -C $HOME/
}

function routable_ip {
  sed -i 's/.*routable_ip/# \0/' "$HOME/massa/massa-node/base_config/config.toml"
  sed -i "/\[network\]/a routable_ip=\"$(curl -s ifconfig.me)\"" "$HOME/massa/massa-node/base_config/config.toml"
}

function keys_from_backup {
	cp $HOME/massa_backup/wallet.dat $HOME/massa/massa-client/wallet.dat
	cp $HOME/massa_backup/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key
    cp $HOME/massa_backup/config.toml $HOME/massa/massa-node/base_config/config.toml
    rm-rf $HOME/massa/massa-node/base_config/bootstrap_whitelist.json
}

colors
echo "Читаем переменные, делаем бекап"
get_env
massa_backup
echo "Удаляем старые файлы"
delete
echo "Скачиваем новую версию и переписываем конфиг"
install
routable_ip
echo "Восстанавливаемся из бекапа"
keys_from_backup
sudo systemctl restart massa
echo "Обновление завершено"