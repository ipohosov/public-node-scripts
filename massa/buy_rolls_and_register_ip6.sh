source .profile
cd /root/massa/massa-client/ 

/root/massa/massa-client/massa-client --pwd $massa_pass buy_rolls $massa_wallet 1 0

# Get IP6 and replace routable ip
server_ip=$(ifconfig | grep inet6 | grep global | awk '{print $2}')
# server_ip=$(hostname -I | awk '{print $1}')
config_path="$HOME/massa/massa-node/base_config/config.toml"
sed -i 's/.*routable_ip/# \0/' $config_path
sed -i "/\[network\]/a routable_ip=\"$server_ip\"" $config_path

# Remove bootstrap_whitelist.json
rm -rf /root/massa/massa-node/base_config/bootstrap_whitelist.json

# Update retry_delay
sed -i -e "s%retry_delay *=.*%retry_delay = 10000%; " "$config_path"


# Get node id
node_id=$(/root/massa/massa-client/massa-client --pwd $massa_pass get_status | grep "Node's ID" | grep -v "IP address" | awk '{print $3}')

# Register node in discord
echo "Your ip is $server_ip"
echo "Enter discord id:"
read discord_id

/root/massa/massa-client/massa-client --pwd $massa_pass node_testnet_rewards_program_ownership_proof $massa_wallet $discord_id

# Print the node info for botstrap
echo '["[$server_ip]:31245", "$node_id"],'