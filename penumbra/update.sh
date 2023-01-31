#!/bin/bash

function install_tools {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
  source ~/.cargo/env
  rustup default nightly
  sleep 1
}

function source_git {
  if [ ! -d $HOME/penumbra/ ]; then
    git clone https://github.com/penumbra-zone/penumbra
  fi
  cd $HOME/penumbra
  git reset --hard
  git fetch
  git checkout $version && cargo update
}

function build_penumbra {
  if [ ! -d $HOME/penumbra/ ]; then
    cd $HOME/penumbra/
    cargo build --release --bin pcli
    sudo rm -f /usr/bin/pcli
    sudo cp target/release/pcli /usr/bin/pcli
  else
    source_git
    cd $HOME/penumbra/
    cargo build --release --bin pcli
    sudo rm -f /usr/bin/pcli
    sudo cp target/release/pcli /usr/bin/pcli
  fi
}

function generate_wallet {
  cd $HOME/penumbra/
  pcli keys generate
}

function reset_wallet {
  cd $HOME/penumbra/
  pcli view reset
}

function rust_update {
  source ~/.cargo/env
  rustup update
  rustup default nightly
}



export version="042-adraste"


echo -e "$1/2 Обновляем репозиторий"
source_git
line
echo -e "2/2 Начинаем билд"
rust_update
line
build_penumbra
reset_wallet
line
echo -e "Скрипт завершил свою работу"