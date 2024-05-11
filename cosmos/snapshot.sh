#!/bin/bash

source $HOME/.profile

read -p "Enter service name: " SERVICE_NAME 
read -p "Enter chain name: " CHAIN_NAME 
read -p "Enter chain home: " CHAIN_HOME 

if [[ -z $SERVICE_NAME || -z $CHAIN_NAME || -z $CHAIN_HOME ]]; then
  echo "ERROR: We can't proceed without service name, chain name, and home dir"
  exit 1
fi

log_this() {
  local logging="$@"
  printf "|$(TZ=":UTC" date '+%Y-%m-%d_%H:%M:%S')| $logging\n"
}

CHAIN_ID=$(jq -r .chain_id "$HOME/$CHAIN_HOME/config/genesis.json")
SNAP_PATH="$HOME/$CHAIN_NAME"
mkdir -p $SNAP_PATH
INFO_FILE_NAME="info.json"
RPC_ADDRESS=$(cat < "$HOME/$CHAIN_HOME/config/config.toml" | grep "laddr = \"tcp://127.0.0.1:" | cut -d '"' -f2 | sed 's/tcp/http/')
BLOCK_HEIGHT=$(curl -s "${RPC_ADDRESS}/status" | jq -r .result.sync_info.latest_block_height)
BLOCK_TIME=$(curl -s "${RPC_ADDRESS}/status" | jq -r .result.sync_info.latest_block_time)

PRUNNING_KEEP_RECENT=$(cat $HOME/$CHAIN_HOME/config/app.toml | grep pruning-keep-recent | awk -F '"' '{print $2}' | grep -v '^$')
PRUNNING_KEEP_EVERY=$(cat $HOME/$CHAIN_HOME/config/app.toml | grep pruning-keep-every | awk -F '"' '{print $2}' | grep -v '^$')
PRUNNING_INTERVAL=$(cat $HOME/$CHAIN_HOME/config/app.toml | grep pruning-interval | awk -F '"' '{print $2}' | grep -v '^$')

log_this "Block height: ${BLOCK_HEIGHT}"
log_this "Block time: ${BLOCK_TIME}"

log_this "Stopping ${SERVICE_NAME}"
sudo systemctl stop "${SERVICE_NAME}"

log_this "Creating new snapshot"
SNAP_NAME="${CHAIN_ID}_latest.tar.lz4"
cd "$HOME/${CHAIN_HOME}" || return
if [[ -d "wasm" ]]; then
  tar --exclude './wasm/wasm/cache/*' -cf - ./data ./wasm | lz4 - "${HOME}/${SNAP_NAME}"
else
  tar --exclude './data/wasm/cache/*' -cf - ./data | lz4 - "${HOME}/${SNAP_NAME}"
fi

log_this "Starting ${SERVICE_NAME}"
sudo systemctl start "${SERVICE_NAME}"

log_this "Moving new snapshot to share drive"
mkdir -p "${SNAP_PATH}"
mv "${HOME}/${CHAIN_ID}"*tar.lz4 "${SNAP_PATH}"
SNAP_SIZE=$(du -hs "${SNAP_PATH}" | awk '{print $1}')
log_this "Snap size: $(du -hs "${SNAP_PATH}")"

log_this "Copy addrbook to share drive"
cp "$HOME/$CHAIN_HOME/config/addrbook.json" "${SNAP_PATH}"

jq -n \
  --arg blockHeight "${BLOCK_HEIGHT}" \
  --arg blockTime "${BLOCK_TIME}" \
  --arg fileName "${SNAP_NAME}" \
  --arg fileSize "${SNAP_SIZE}" \
  --arg pruningKeepRecent "${PRUNNING_KEEP_RECENT}" \
  --arg pruningKeepEvery "${PRUNNING_KEEP_EVERY}" \
  --arg pruningInterval "${PRUNNING_INTERVAL}" \
  '{
    blockHeight: $blockHeight,
    blockTime: $blockTime,
    fileName: $fileName,
    fileSize: $fileSize,
    pruningKeepRecent: $pruningKeepRecent,
    pruningKeepEvery: $pruningKeepEvery,
    pruningInterval: $pruningInterval,
  }' >"${SNAP_PATH}/${INFO_FILE_NAME}"
