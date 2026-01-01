#!/bin/env bash

set -e

echo checking if lima is installed

command -v lima &>/dev/null && {
  echo lima is already installed
  exit 0
}

OS=$(uname)

# for macos
if [[ $OS == "Darwin" ]]; then
  brew list lima lima-additional-guestagents &>/dev/null || {
    brew update
    brew upgrade
    echo installing lima
    brew install lima lima-additional-guestagents
  }
elif [[ $OS == "Linux" ]]; then
  
  VERSION=$(curl -fsSL https://api.github.com/repos/lima-vm/lima/releases/latest | jq -r .tag_name)
  curl -fsSL "https://github.com/lima-vm/lima/releases/download/${VERSION}/lima-${VERSION:1}-$(uname -s)-$(uname -m).tar.gz" | sudo tar Cxzvm /usr/local
  curl -fsSL "https://github.com/lima-vm/lima/releases/download/${VERSION}/lima-additional-guestagents-${VERSION:1}-$(uname -s)-$(uname -m).tar.gz" | sudo tar Cxzvm /usr/local

fi

