#!/bin/bash

function install_tools {
  sudo apt update && sudo apt install mc wget htop jq git ocl-icd-opencl-dev libopencl-clang-dev libgomp1 expect -y
  swapfile="/swapfile"
  if swapon -s | grep -qF "$swapfile"; then
    echo "Своп-файл $swapfile существует и активен."
  else
    echo "Своп-файл $swapfile не существует или не активен."
    sudo fallocate -l 8G /swapfile
    sudo mkswap /swapfile
    sudo chmod 600 /swapfile
    sudo swapon /swapfile
  fi
}

function wget_pulsar {
  URL="https://github.com/subspace/pulsar/releases/download/v0.6.6-alpha/pulsar-ubuntu-x86_64-skylake-v0.6.6-alpha"
  wget -O pulsar $URL
  sudo chmod +x pulsar
  sudo mv pulsar /usr/local/bin/
}

function read_nodename {
  if [ ! $SUBSPACE_NODENAME ]; then
  echo -e "Enter your node name(random name for telemetry)"
  read SUBSPACE_NODENAME
  export SUBSPACE_NODENAME
  sleep 1
  fi
}

function read_wallet {
  if [ ! $WALLET_ADDRESS ]; then
  echo -e "Enter your polkadot.js extension address"
  read WALLET_ADDRESS
  export WALLET_ADDRESS
  sleep 1
  fi
}

function systemd {
  sudo tee <<EOF >/dev/null /etc/systemd/system/subspace.service
[Unit]
Description=Subspace Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/pulsar farm --verbose
Restart=on-failure
LimitNOFILE=548576:1048576

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable subspace
sudo systemctl restart subspace
}

function output_after_install {
    echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 5
    if [[ `systemctl status subspace | grep active` =~ "running" ]]; then
        echo -e "Your Subspace node \e[32minstalled and works\e[39m!"
        echo -e "You can check node status by the command \e[7msystemctl status subspace\e[0m"
        echo -e "Press \e[7mQ\e[0m for exit from status menu"
    else
        echo -e "Your Subspace node \e[31mwas not installed correctly\e[39m, please reinstall."
    fi
}

function main {
    read_nodename
    read_wallet
    install_tools
    wget_pulsar
    sudo rm -rf $HOME/.config/pulsar
    pulsar init
    systemd
    output_after_install
}

main