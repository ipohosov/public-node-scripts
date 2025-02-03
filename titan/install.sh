#!/bin/bash

sudo apt update
sudo apt install snapd
sudo systemctl enable --now snapd.socket
sudo snap install multipass
multipass --version

echo "Введите KEY: "
read KEY

wget https://pcdn.titannet.io/test4/bin/agent-linux.zip
mkdir -p /root/opt/titanagent
unzip agent-linux.zip -d /root/opt/titanagent
rm -rf agent-linux.zip

sudo tee /etc/systemd/system/titan.service > /dev/null << EOF
[Unit]
Description=Titan Node Service
After=network.target
Wants=network-online.target

[Service]
ExecStart=/root/opt/titanagent/agent --working-dir=/root/opt/titanagent --server-url=https://test4-api.titannet.io --key=$KEY
Restart=always
RestartSec=5
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=titan-node
WorkingDirectory=$HOME/opt/titanagent

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable titan
sudo systemctl start titan

\