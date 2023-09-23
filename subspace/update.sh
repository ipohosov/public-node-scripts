# Останавливаем сервис subspace
sudo systemctl stop subspace
(crontab -l ; echo "0 * * * * truncate -s 0 \$HOME/.local/share/pulsar/logs/*.log*") | crontab -

URL="https://github.com/subspace/pulsar/releases/download/v0.6.9-alpha/pulsar-ubuntu-x86_64-skylake-v0.6.9-alpha"

rm -f /usr/local/bin/pulsar
wget -O pulsar $URL
sudo chmod +x pulsar
sudo mv pulsar /usr/local/bin/

sudo systemctl restart subspace