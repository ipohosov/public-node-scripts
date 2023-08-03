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
bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa/install_massa.sh)
```
Update
```
bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa/update_massa.sh)
```
2. Wait bootstrapping and configure massa
```
bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa/massa_configuration.sh)
```

Thanks Double Top team for installation/update script

### 6. holograph_healthcheck
1. Install tmux:
```
apt install tmux -y
```
2. Start tmux session:
```
tmux new-session -d -s holograph_healthcheck 'bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/holograph/holograph_healthcheck.sh)'
```
3. Remove session
```
tmux kill-session -t holograph_healthcheck
```