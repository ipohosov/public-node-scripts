#!/usr/bin/env bash
cd $HOME

systemctl stop artela
systemctl daemon-reload

cd ~/.artelad && mkdir -p libs && cd libs

wget https://github.com/artela-network/artela/releases/download/v0.4.7-rc7-fix-execution/artelad_0.4.7_rc7_fix_execution_Linux_amd64.tar.gz
rm -rf artelad libaspect_wasm_instrument.so
tar -xvf artelad_0.4.7_rc7_fix_execution_Linux_amd64.tar.gz
rm -rf /root/go/bin/artelad
rm -rf artelad_0.4.7_rc7_fix_execution_Linux_amd64.tar.gz

cd $HOME

echo 'export LD_LIBRARY_PATH=/root/.artelad/libs:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export PATH="$PATH:/root/.artelad/libs"' >> ~/.bashrc

source ~/.bashrc

sed -i 's/iavl-disable-fastnode = false/iavl-disable-fastnode = true/' ~/.artelad/config/app.toml

artelad rollback --hard

rm -rf /etc/systemd/system/artela.service

sudo tee /etc/systemd/system/artela.service > /dev/null << EOF
[Unit]
Description=Artela node service
After=network-online.target
[Service]
User=root
ExecStart=/root/.artelad/libs/artelad start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="LD_LIBRARY_PATH=/root/.artelad/libs"
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl start artela