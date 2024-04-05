#!/usr/bin/env bash

sudo rm -rf /usr/local/go
curl -L https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
source .bash_profile

sudo apt install build-essential jq wget git curl  -y
cd $HOME
git clone https://github.com/artela-network/artela.git
cd artela
git checkout v0.4.7-rc6