#/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function delete {
  sudo systemctl stop massa
  rm -rf $HOME/massa
}

function massa_backup {
	cd $HOME
	if [ ! -d $HOME/massa_backup17/ ]; then
		mkdir -p $HOME/massa_backup17
		cp $HOME/massa/massa-node/config/node_privkey.key $HOME/massa_backup19/
		cp $HOME/massa/massa-client/wallet.dat $HOME/massa_backup19/
    cp $HOME/massa/massa-node/config/base_config/config.toml $HOME/massa_backup19/
	fi
}

function install {
  wget https://github.com/massalabs/massa/releases/download/TEST.19.1/massa_TEST.19.1_release_linux.tar.gz
  tar zxvf massa_TEST.19.1_release_linux.tar.gz -C $HOME/
}

function routable_ip {
  sed -i 's/.*routable_ip/# \0/' "$HOME/massa/massa-node/base_config/config.toml"
  sed -i "/\[network\]/a routable_ip=\"$(curl -s ifconfig.me)\"" "$HOME/massa/massa-node/base_config/config.toml"
}

function massa_pass {
  if [ ! ${massa_pass} ]; then
  echo "Введите свой пароль для клиента(придумайте)"
  read massa_pass
  echo "export massa_pass=$massa_pass" >> $HOME/.profile
  source $HOME/.profile
  fi
}

function systemd {
  sudo tee <<EOF >/dev/null /etc/systemd/system/massa.service
[Unit]
Description=Massa Node
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/massa/massa-node
ExecStart=$HOME/massa/massa-node/massa-node -p "$massa_pass"
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable massa
sudo systemctl restart massa
}

function alias {
  echo "alias client='cd $HOME/massa/massa-client/ && $HOME/massa/massa-client/massa-client --pwd $massa_pass && cd'" >> ~/.profile
  echo "alias clientw='cd $HOME/massa/massa-client/ && $HOME/massa/massa-client/massa-client --pwd $massa_pass && cd'" >> ~/.profile
}

function keys_from_backup {
	cp $HOME/massa_backup19/wallet.dat $HOME/massa/massa-client/wallet.dat
	cp $HOME/massa_backup19/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key
  cp $HOME/massa_backup19/config.toml $$HOME/massa/massa-node/config/base_config/config.toml
  rm -rf $$HOME/massa/massa-node/config/base_config/bootstrap_whitelist.json.json
}
  

colors
massa_backup
massa_pass
delete
install
routable_ip
keys_from_backup
systemd
alias
echo "Готово, ваш пароль от клиента - $massa_pass"