#!/bin/bash

#add ufw rules
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash

sudo apt update
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash

#
source $HOME/.cargo/env
sleep 1
rustup toolchain install nightly
rustup default nightly
cd $HOME
if [ ! -d $HOME/massa/ ]; then
	git clone https://github.com/massalabs/massa
	cd $HOME/massa && git checkout TEST.23.2
fi
cd $HOME/massa/massa-node/
cargo build --release
#sed -i 's%bootstrap_list *=.*%bootstrap_list = [ [ "62.171.166.224:31245", "8Cf1sQA9VYyUMcDpDRi2TBHQCuMEB7HgMHHdFcsa13m4g6Ee2h",], [ "149.202.86.103:31245", "5GcSNukkKePWpNSjx9STyoEZniJAN4U4EUzdsQyqhuP3WYf6nj",], [ "149.202.89.125:31245", "5wDwi2GYPniGLzpDfKjXJrmHV3p1rLRmm4bQ9TUWNVkpYmd4Zm",], [ "158.69.121.015:31245", "5QbsTjSoKzYc8uBbwPCap392CoMQfZ2jviyq492LZPpijctb9c",], [ "158.69.23.120:31245", "8139kbee951YJdwK99odM7e6V3eW7XShCfX5E2ovG3b9qxqqrq",],]%' "$HOME/massa/massa-node/base_config/config.toml"
sed -i "s/ip *=.*/ip = \"127\.0\.0\.1\"/" "$HOME/massa/massa-client/base_config/config.toml"
sed -i "s/^bind_private *=.*/bind_private = \"127\.0\.0\.1\:33034\"/" "$HOME/massa/massa-node/base_config/config.toml"
sed -i "s/^bind_public *=.*/bind_public = \"0\.0\.0\.0\:33035\"/" "$HOME/massa/massa-node/base_config/config.toml"
sed -i 's/.*routable_ip/# \0/' "$HOME/massa/massa-node/base_config/config.toml"
sed -i "/\[network\]/a routable_ip=\"$(curl -s ifconfig.me)\"" "$HOME/massa/massa-node/base_config/config.toml"

sudo tee <<EOF >/dev/null /etc/systemd/system/massa.service
[Unit]
Description=Massa Node
After=network-online.target
[Service]
User=$USER
Restart=always
RestartSec=3
LimitNOFILE=65535
WorkingDirectory=$HOME/massa/massa-node
ExecStart=$HOME/massa/target/release/massa-node
[Install]
WantedBy=multi-user.target
EOF

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF

sudo systemctl restart systemd-journald
sudo systemctl enable massa
sudo systemctl daemon-reload
sudo systemctl restart massa

cd $HOME/massa/massa-client/
cargo run -- --wallet wallet.dat wallet_generate_private_key


echo "alias client='cd $HOME/massa/massa-client/ && cargo run --release && cd'" >> ~/.profile
echo "alias clientw='cd $HOME/massa/massa-client/; cargo run -- --wallet wallet.dat; cd'" >> ~/.profile

while true
do
  printf "Check massa logs \n"
  if [ "$(journalctl -n 50 -u massa --no-pager | grep -c "final_state hash at slot")" -gt 1 ]; then
    break
  fi
  sleep 10s
done


# Create a wallet
echo "Create a wallet"
cd /root/massa/massa-client/ 
./massa-client --pwd $massa_pass wallet_generate_secret_key > /dev/null

wallet_info=$(./massa-client --pwd $massa_pass wallet_info)

if [[ $wallet_info =~ Address:\ ([A-Za-z0-9]+) ]]; then
massa_wallet="${BASH_REMATCH[1]}"
else
echo "No match found."
fi

echo "Massa wallet: $massa_wallet"

# Start staking 
./massa-client --pwd $massa_pass node_start_staking $massa_wallet > /dev/null

# Waiting faucet
echo "Go to discord to the faucet"
echo "Waiting for the faucet"
while true
do
balance=$(./massa-client --pwd $massa_pass wallet_info | grep "Balance" | awk '{ print $3 }' | sed 's/candidate=//;s/,//')
int_balance=${balance%%.*}
if [ $int_balance -lt "1" ]; then
  sleep 5s
  echo "."
elif [ $int_balance -gt "1" ]; then
  break
fi
done

# Buy roll 
echo "Buy roll"
./massa-client --pwd $massa_pass buy_rolls $massa_wallet 1 0  > /dev/null


# Register node in discord
echo "Enter discord id:"
read discord_id

./massa-client --pwd $massa_pass node_testnet_rewards_program_ownership_proof $massa_wallet $discord_id


# Get node id
echo "Get node id"
node_id=$(./massa-client --pwd $massa_pass get_status | grep "Node's ID" | grep -v "IP address" | awk '{print $3}')

# Get IP
echo "Get IP"
ifconfig | grep -q 'inet6'
if [[ $? -eq 0 ]]; then
  server_ip=$(ifconfig | grep inet6 | grep global | awk '{print $2}')
  echo "Get IPv6 $server_ip"
else
  server_ip=$(hostname -I | awk '{print $1}')
  echo "Get IPv4 $server_ip"
fi


# Setup extra scripts
echo "The current active scripts"
tmux kill-session -t rolls  > /dev/null
tmux kill-session -t massa_healthcheck  > /dev/null
tmux new-session -d -s massa_healthcheck 'bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa/massa_healthcheck.sh)'  > /dev/null
tmux new-session -d -s rolls 'bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa/rolls.sh)'  > /dev/null
tmux ls

# Print the node info for botstrap
echo "Node data for bootstrap"
echo "[\"[$server_ip]:31245\", \"$node_id\"]"
