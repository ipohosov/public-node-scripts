#!/bin/bash

printBlue() {
    echo -e "\e[34m$1\e[0m"
}

printGreen() {
    echo -e "\e[32m$1\e[0m"
}

error_exit() {
    echo "$1" 1>&2
    exit 1
}

if [ "$EUID" -ne 0 ]; then
    error_exit "This script requires administrator rights. Run it with sudo privileges."
fi


printBlue "     _   _       _     _       _           "            
printBlue "    | \ | |_   _| |   (_)_ __ | | __       "            
printBlue "    |  \| | | | | |   | | '_ \| |/ /       "           
printBlue "    | |\  | |_| | |___| | | | |   <        "            
printBlue "    |_| \_|\__,_|_____|_|_| |_|_|\_\       "            

sleep 5

echo ""
printGreen "Open the ports" & sleep 2
sudo ufw allow 9151
sudo ufw allow 9151/tcp

echo ""
printGreen "Update the server" & sleep 2
echo ""
sudo apt update
sudo apt install python3.9 -y
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

echo ""
printGreen "Download geth" & sleep 2
wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.23-d901d853.tar.gz
tar -xvzf geth-linux-amd64-1.10.23-d901d853.tar.gz
rm -rf geth-linux-amd64-1.10.23-d901d853.tar.gz

echo ""
printGreen "Go to the folder" & sleep 2
echo ""
cd geth-linux-amd64-1.10.23-d901d853/

echo ""
printGreen "Create an Ethereum account and a keystore" & sleep 2
printGreen "You will be prompted to enter the password and confirm the password. Please remember this password for late use." & sleep 2
echo ""
./geth account new --keystore ./keystore

echo ""
printGreen "Continue the installation if you saved the password you entered, public address of the key, and path of the secret key file" & sleep 2
echo ""
read -p "Continue installation? (y/n): " choice
case "$choice" in
  y|Y ) 
    echo "Continuation..." & sleep 2
    ;;
  n|N ) 
    echo "Cancelled."
    exit 0
    ;;
  * ) 
    echo "Please enter 'y' or 'n'."
    exit 1
    ;;
esac

echo ""
printGreen "Downloading the latest NuLink image" & sleep 2
echo ""
sudo docker pull nulink/nulink:latest

echo ""
printGreen "Create a NuLink folder" & sleep 2
echo ""
cd $HOME
sudo mkdir nulink

echo ""
printGreen "We check whether the folder has been created" & sleep 2
echo ""
if [ -d $HOME/nulink ]; then
    echo "The folder exists." & sleep 2
else
    echo "The folder does not exist." & sleep 2
fi

echo ""
printGreen "If the folder exists, continue the installation" & sleep 2
echo ""
read -p "Continue installation? (y/n): " choice
case "$choice" in
  y|Y ) 
    echo "Continuation..." & sleep 2
    ;;
  n|N ) 
    echo "Cancelled."
    exit 0
    ;;
  * ) 
    echo "Please enter 'y' or 'n'."
    exit 1
    ;;
esac
echo ""
printGreen "Copying your repository, enter your value, for example: UTC--2024-02-17T19-37-42.712584935Z--02b2d1f206126cdb0b9a19c5c5b44d6c84ec8e2c" & sleep 2
echo ""
read -p "Your UTC: " UTC 
cp $HOME/geth-linux-amd64-1.10.23-d901d853/keystore/$UTC /root/nulink

echo ""
printGreen "Check if the UTC file has been copied" & sleep 2
echo ""
cd $HOME/nulink
ls -la

echo ""
printGreen "If you see your UTC file, continue with the installation" & sleep 2
echo ""
read -p "Continue installation? (y/n): " choice
case "$choice" in
  y|Y ) 
    echo "Continuation..." & sleep 2
    ;;
  n|N ) 
    echo "Cancelled."
    exit 0
    ;;
  * ) 
    echo "Please enter 'y' or 'n'."
    exit 1
    ;;
esac

cd $HOME

echo ""
printGreen "Permission granted to the NuLink folder" & sleep 2
echo ""
chmod -R 777 $HOME/nulink

printGreen "Set the passwords that were specified when creating Ethereum" & sleep 2
echo ""
read -p "Enter your password: " PASSWORD 
export NULINK_KEYSTORE_PASSWORD=$PASSWORD
export NULINK_OPERATOR_ETH_PASSWORD=$PASSWORD

echo ""
printGreen "Check if your passwords are displayed, two of your passwords should be displayed" & sleep 2
echo ""
echo $NULINK_KEYSTORE_PASSWORD
echo $NULINK_OPERATOR_ETH_PASSWORD

read -p "Continue installation? (y/n): " choice
case "$choice" in
  y|Y ) 
    echo "Continuation..." & sleep 2
    ;;
  n|N ) 
    echo "Cancelled."
    exit 0
    ;;
  * ) 
    echo "Please enter 'y' or 'n'."
    exit 1
    ;;
esac
echo ""
printGreen "Initializing the node configuration"
echo ""
printGreen "Replacing Public address of the key and Path of the secret key file" & sleep 2
printGreen "Example: UTC--2024-02-17T19-37-42.712584935Z--02b2d1f206126cdb0b9a19c5c5b44d6c84ec8e2c" 
printGreen "Example: 0x...................." 
read -p "Public address of the key: " ADDRESS



docker run -it --rm \
-p 9151:9151 \
-v /root/nulink:/code \
-v /root/nulink:/home/circleci/.local/share/nulink \
-e NULINK_KEYSTORE_PASSWORD \
nulink/nulink nulink ursula init \
--signer keystore:///code/$UTC \
--eth-provider https://data-seed-prebsc-2-s2.binance.org:8545 \
--network horus \
--payment-provider https://data-seed-prebsc-2-s2.binance.org:8545 \
--payment-network bsc_testnet \
--operator-address $ADDRESS \
--max-gas-price 10000000000

echo ""
printGreen "We start the node" & sleep 2
docker run --restart on-failure -d \
--name ursula \
-p 9151:9151 \
-v /root/nulink:/code \
-v /root/nulink:/home/circleci/.local/share/nulink \
-e NULINK_KEYSTORE_PASSWORD \
-e NULINK_OPERATOR_ETH_PASSWORD \
nulink/nulink nulink ursula run --no-block-until-ready



echo ""
echo ""
printGreen "If you saw the inscription, for example: Operator 0x.................... is not bonded to a staking provider" sleep 2
printGreen "Go to the dashboard, send 0.1 BNB to the worker address and stake 10 NLK" sleep 2
printGreen "If you see a different result, write to us in Discord" & sleep 2
echo ""
printGreen "Checking the status, logs, a possible delay of 1 minute, please wait"
echo ""
docker logs -f ursula

