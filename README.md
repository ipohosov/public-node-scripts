# Scripts for Crypto projects

Donates TRC20 - TZ7pxizxodsy8J52D5FZzQFp3X5DSpyB1X
#

## Scripts list

### 1. massa_healthcheck

1. Install tmux:
```
apt install tmux -y
```
2. Start tmux session:
```
tmux new-session -d -s massa_healthcheck 'bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa/massa_healthcheck.sh)'
```
3. Remove session
```
tmux kill-session -t massa_healthcheck
```

### 2. ironfish_quests

1. Execute script
```
bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/ironfish/ironfish_quests.sh)
```

### 3. bundlr_healthcheck

1. Install tmux:
```
apt install tmux -y
```
2. Start tmux session:
```
tmux new-session -d -s bundlr_healthcheck 'bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/bundlr/bundlr_healthcheck.sh)'
```
3. Remove session
```
tmux kill-session -t bundlr_healthcheck
```

### 4. shardeum healthcheck

1. Start tmux session
```
tmux new-session -d -s shardeum_healthcheck 'bash <(curl -s  https://github.com/ipohosov/public-node-scripts/blob/main/shardeum/shardeum_healthcheck.sh)'
```

## Usefull commands
1. Check the list of active tmux sessions:
```
tmux ls
```
2. Check the logs in active tmux sesion:
```
tmux attach -t session_name
```
To deattach from session press CTRL+B and then D.

### 5. Massa setup
1. Update or install massa

Setup
```
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/massa/clear_massa.sh)
```
Update
```
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/massa/update.sh)
```
2. Create wallet and stake
```
bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa/create_and_stake.sh)
```
3. Go to discord for faucet
4. Buy rolls, edit config.toml, remove bootstrap_whitelist.json, register node in discord. The command depands on ip version
```
bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa/buy_rolls_and_register_ip4.sh)
```
or
```
bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa/buy_rolls_and_register_ip6.sh)
```
5. Go to discord and post output

Thanks Double Top team for installation/update script