#!/usr/bin/env bash

# this install and un VS Code tunnel

OS=$(uname)
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH=x64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

[ -f ./code ] || {
  curl -Lk "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-${ARCH}" --output vscode_cli.tar.gz
  tar -xf vscode_cli.tar.gz
}

./code tunnel
