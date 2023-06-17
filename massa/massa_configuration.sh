# Clean up the .profile
echo "Clean up the profile"
awk '!x[$0]++' .profile > .profile2 && rm -rf .profile && cp .profile2 .profile && rm -rf .profile2
source .profile

# Create a wallet
echo "Create a wallet"
cd /root/massa/massa-client/ 
./massa-client --pwd $massa_pass wallet_generate_secret_key > /dev/null

wallet_info=$(./massa-client --pwd $massa_pass wallet_info)

if [[ $wallet_info =~ Address:\ ([A-Za-z0-9]+) ]]; then
  massa_wallet="${BASH_REMATCH[1]}"
  echo "Matched value: $massa_wallet"
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

# Register node in discord
echo "Enter discord id:"
read discord_id

./massa-client --pwd $massa_pass node_testnet_rewards_program_ownership_proof $massa_wallet $discord_id

# Setup extra scripts
echo "The current active scripts"
tmux kill-session -t rolls  > /dev/null
tmux kill-session -t massa_healthcheck  > /dev/null
tmux new-session -d -s massa_healthcheck 'bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa/massa_healthcheck.sh)'  > /dev/null
tmux new-session -d -s rolls 'bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa/rolls.sh)'  > /dev/null
tmux ls

# Print the node info for botstrap
echo "Node data for bootstrap"
echo "[\"[$server_ip]:31245\", \"$node_id\"],"
