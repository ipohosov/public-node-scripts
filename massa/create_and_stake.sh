# Clean up the profile
awk '!x[$0]++' .profile > .profile2 && rm -rf .profile && cp .profile2 .profile && rm -rf .profile2
source .profile

# Create a wallet
cd /root/massa/massa-client/ 
/root/massa/massa-client/massa-client --pwd $massa_pass wallet_generate_secret_key

wallet_info=$(/root/massa/massa-client/massa-client --pwd $massa_pass wallet_info)

if [[ $wallet_info =~ Address:\ ([A-Za-z0-9]+) ]]; then
  massa_wallet="${BASH_REMATCH[1]}"
  echo "Matched value: $massa_wallet"
else
  echo "No match found."
fi

echo "massa_wallet=$massa_wallet" >> ~/.profile

# Start staking 
/root/massa/massa-client/massa-client --pwd $massa_pass node_start_staking $massa_wallet

echo "Massa wallet $massa_wallet"

cd ..
cd ..