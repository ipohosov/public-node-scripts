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

function install {
  wget https://github.com/massalabs/massa/releases/download/TEST.19.0/massa_TEST.19.0_release_linux.tar.gz
  tar zxvf massa_TEST.19.0_release_linux.tar.gz -C $HOME/
}

function routable_ip {
  sed -i 's/.*routable_ip/# \0/' "$HOME/massa/massa-node/base_config/config.toml"
  sed -i "/\[network\]/a routable_ip=\"$(curl -s ifconfig.me)\"" "$HOME/massa/massa-node/base_config/config.toml"
}

function massa_pass {
  if [ ! ${massa_pass} ]; then
  echo "Введите свой пароль для клиента(придумайте)"
  read massa_pass
  fi
  echo "export massa_pass=$massa_pass" >> $HOME/.profile
  source $HOME/.profile
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

colors
massa_pass
delete
install
routable_ip
systemd
alias
echo "Готово, ваш пароль от клиента - $massa_pass"