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
tmux new-session -d -s massa_healthcheck 'bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa_healthcheck.sh)'
```
3. Remove session
```
tmux kill-session -t massa_healthcheck
```

### 2. ironfish_quests

1. Setup email, that was used for ironfish node(change 'your_email' in command to appropriate email). You need to do it only once to add email to .profile. If you want to change email by some reason you need to edit the value of IRONFISH_EMAIL in this file:
```
echo 'export IRONFISH_EMAIL=your_email' >> $HOME/.profile
```

2. Install tmux:
```
apt install tmux -y
```
3. Start tmux session:
```
tmux new-session -d -s ironfish_quests 'bash <(curl -s https://raw.githubusercontent.com/ipohosov/public-node-scripts/main/massa_healthcheck.sh)'
```
4. Remove session
```
tmux kill-session -t ironfish_quests
```

### 3. ironfish_faucet

This script is helpful for script ironfish_quests. It's copied and executed inside docker container.


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