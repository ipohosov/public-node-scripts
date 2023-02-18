#!/bin/bash

echo "Set variables"
echo "export ADDRESS=$(hostname -I | cut -f1 -d' ')" >> $HOME/.profile
source $HOME/.profile

# update
echo "Setup dependencies"
sudo apt update && sudo apt upgrade -y
apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

echo "Download lates version of lamina1"
wget https://lamina1.github.io/lamina1/lamina1.latest.ubuntu-latest.tar.gz
tar -xvzf lamina1.latest.ubuntu-latest.tar.gz
rm -rf lamina1.latest.ubuntu-latest.tar.gz
cd lamina1

echo "Update configs"
sed -i -e "s/public-ip-resolution-service/public-ip/g" $HOME/lamina1/configs/testnet4/default.json
sed -i -e "s/opendns/$ADDRESS/g" $HOME/lamina1/configs/testnet4/default.json

#service
sudo tee /etc/systemd/system/lamina1.service > /dev/null <<EOF
[Unit]
Description=lamina1
After=network-online.target
[Service]
User=root
WorkingDirectory=/root/lamina1
ExecStart=/root/lamina1/lamina1-node  --config-file /root/lamina1/configs/testnet4/default.json
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

echo "Start lamina1"
systemctl daemon-reload
systemctl enable lamina1
systemctl restart lamina1
