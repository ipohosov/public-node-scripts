#!/usr/bin/env bash
cd $HOME

systemctl stop artela
systemctl daemon-reload

sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y

echo "export WALLET="NAME YOU WANT YOUR WALLET TO HAVE"" >> $HOME/.bash_profile
echo "export MONIKER="test"" >> $HOME/.bash_profile
echo "export ARTELA_CHAIN_ID="artela_11822-1"" >> $HOME/.bash_profile
echo "export ARTELA_PORT="30"" >> $HOME/.bash_profile
source $HOME/.bash_profile

cd $HOME
rm -rf artela
git clone https://github.com/artela-network/artela
cd artela
git checkout v0.4.7-rc7-fix-execution
make install
cd 
wget https://github.com/artela-network/artela/releases/tag/v0.4.7-rc7-fix-execution/artelad_0.4.7_rc7_fix_execution_Linux_amd64.tar.gz
mkdir test_latest
tar -xvf artelad_0.4.7_rc7_fix_execution_Linux_amd64.tar.gz -C ./test_latest
mv ./test_latest/artelad $HOME/go/bin/artelad
echo 'export LD_LIBRARY_PATH=$HOME/test_latest:$LD_LIBRARY_PATH' >> ~/.bashrc
source .bashrc


cd artela
artelad config node tcp://localhost:${ARTELA_PORT}657
artelad config keyring-backend os
artelad config chain-id artela_11822-1
artelad init $MONIKER --chain-id artela_11822-1
cd 
cd .artelad
mkdir libs
cd
mv ./test_latest/libaspect_wasm_instrument.so $HOME/.artelad/libs/
echo 'export LD_LIBRARY_PATH=$HOME/.artelad/libs:$LD_LIBRARY_PATH' >> ~/.bashrc
rm -rf test_latest
source .bashrc

rm .artelad/data/c
mv priv_validator_state.json ./.artelad/data/ #in case you already have imported your saved priv validator key in your home dir


SEEDS="8d0c626443a970034dc12df960ae1b1012ccd96a@artela-testnet-seed.itrocket.net:30656"
PEERS="5c9b1bc492aad27a0197a6d3ea3ec9296504e6fd@artela-testnet-peer.itrocket.net:30656,a3766471aac8d2b7fef4b89dc2bc183d32b7a84a@101.47.15.115:3456,e16dccb4d8f3101186fe5938c7cdacb347bb2d7e@130.185.119.252:3456,842b9ecbaf9186fcb44933b1d18aff102d367002@185.249.225.85:3456,180b0b266678dc27ea778ea513c3b9f31213da77@109.199.105.132:25656,78a145c45a617ec14ae6a9f473c9d72f3a7df5fb@109.199.119.246:30656,fee30216aa088a90fba8d82347a735ca959cd646@173.212.223.120:25656,26a8014f42bffddda0473a53b7cf23aada1023eb@84.247.166.118:3456,76cc4ebf230324b67fb56508f0dff075ba9560f4@77.237.245.135:3456,7893e0c798777d7fed32c0e516142cd25a2d79bc@173.249.36.218:25656,d1d43cc7c7aef715957289fd96a114ecaa7ba756@65.21.198.100:23410"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.artelad/config/config.toml


sed -i.bak -e "s%:1317%:${ARTELA_PORT}317%g;
s%:8080%:${ARTELA_PORT}080%g;
s%:9090%:${ARTELA_PORT}090%g;
s%:9091%:${ARTELA_PORT}091%g;
s%:8545%:${ARTELA_PORT}545%g;
s%:8546%:${ARTELA_PORT}546%g;
s%:6065%:${ARTELA_PORT}065%g" $HOME/.artelad/config/app.toml

sed -i.bak -e "s%:26658%:${ARTELA_PORT}658%g;
s%:26657%:${ARTELA_PORT}657%g;
s%:6060%:${ARTELA_PORT}060%g;
s%:26656%:${ARTELA_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${ARTELA_PORT}656\"%;
s%:26660%:${ARTELA_PORT}660%g" $HOME/.artelad/config/config.toml


sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.artelad/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.artelad/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.artelad/config/app.toml


sudo tee /etc/systemd/system/artelad.service > /dev/null <<EOF
[Unit]
Description=Artela node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.artelad
Environment="LD_LIBRARY_PATH=/root/.artelad/libs"
ExecStart=$(which artelad) start --home $HOME/.artelad
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

artelad tendermint unsafe-reset-all --home $HOME/.artelad
if curl -s --head curl https://testnet-files.itrocket.net/artela/snap_artela.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
  curl https://testnet-files.itrocket.net/artela/snap_artela.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.artelad
    else
  echo no have snap
fi

# enable and start service
sudo systemctl daemon-reload
sudo systemctl enable artelad
sudo systemctl restart artelad && sudo journalctl -u artelad -f

artelad keys add $WALLET --recover

WALLET_ADDRESS=$(artelad keys show $WALLET -a)
VALOPER_ADDRESS=$(artelad keys show $WALLET --bech val -a)
echo "export WALLET_ADDRESS="$WALLET_ADDRESS >> $HOME/.bash_profile
echo "export VALOPER_ADDRESS="$VALOPER_ADDRESS >> $HOME/.bash_profile
source $HOME/.bash_profile

artelad tx staking create-validator \
--amount 1000000uart \
--from $WALLET \
--commission-rate 0.1 \
--commission-max-rate 0.2 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--pubkey $(artelad tendermint show-validator) \
--moniker $MONIKER \
--identity "YOUR KEYBASE PGPK" \
--website "your website" \
--details "I love blockchain ❤️" \
--chain-id artela_11822-1 \
--gas auto --gas-adjustment 1.5 \
-y

