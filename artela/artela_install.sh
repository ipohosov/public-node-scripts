#!/usr/bin/env bash

 wget https://github.com/artela-network/artela/releases/download/v0.4.7-rc6/artelad_0.4.7_rc6_Linux_amd64.tar.gz
 tar -xvf  artelad_0.4.7_rc6_Linux_amd64.tar.gz
cp artelad /root/go/bin/
rm -rf artelad artelad_0.4.7_rc6_Linux_amd64.tar.gz

artelad config chain-id artela_11822-1
artelad config keyring-backend test
artelad config node tcp://localhost:26657
artelad init $BABYLON_MONIKER  --chain-id artela_11822-1
curl -L https://snapshots-testnet.nodejumper.io/artela-testnet/genesis.json > $HOME/.artelad/config/genesis.json
curl -L https://snapshots-testnet.nodejumper.io/artela-testnet/addrbook.json > $HOME/.artelad/config/addrbook.json
sed -i -e 's|^seeds *=.*|seeds = "211536ab1414b5b9a2a759694902ea619b29c8b1@47.251.14.47:26656,d89e10d917f6f7472125aa4c060c05afa78a9d65@47.251.32.165:26656,bec6934fcddbac139bdecce19f81510cb5e02949@47.254.24.106:26656,32d0e4aec8d8a8e33273337e1821f2fe2309539a@47.88.58.36:26656,1bf5b73f1771ea84f9974b9f0015186f1daa4266@47.251.14.47:26656"|' $HOME/.artelad/config/config.toml
sed -i -e 's|^minimum-gas-prices *=.*|minimum-gas-prices = "20000000000uart"|' $HOME/.artelad/config/app.toml
sed -i   -e 's|^pruning *=.*|pruning = "custom"|'   -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|'   -e 's|^pruning-interval *=.*|pruning-interval = "17"|'   $HOME/.artelad/config/app.toml
curl "https://snapshots-testnet.nodejumper.io/artela-testnet/artela-testnet_latest.tar.lz4" | lz4 -dc - | tar -xf - -C "$HOME/.artelad"
sed -E 's/^pool-size[[:space:]]*=[[:space:]]*[0-9]+$/apply-pool-size = 10\nquery-pool-size = 30/' ~/.artelad/config/app.toml > ~/.artelad/config/temp.app.toml && mv ~/.artelad/config/temp.app.toml ~/.artelad/config/app.toml

sudo tee /etc/systemd/system/artela.service > /dev/null << EOF
[Unit]
Description=Artela node service
After=network-online.target
[Service]
User=root
ExecStart=/root/go/bin/artelad start --log_level debug
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable artela.service
systemctl start artela.service