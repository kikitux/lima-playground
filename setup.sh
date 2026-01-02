#!/bin/env bash

set -e

OS=$(uname)
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

echo "Detected OS: $OS, Arch: $ARCH"

# --- Lima Installation ---
echo "Checking lima installation..."
if command -v lima &>/dev/null; then
  echo "lima is already installed"
else
  if [[ $OS == "Darwin" ]]; then
    brew list lima lima-additional-guestagents &>/dev/null || {
      brew update
      brew upgrade
      echo "Installing lima..."
      brew install lima lima-additional-guestagents
    }
  elif [[ $OS == "Linux" ]]; then
    echo "Installing lima..."
    # Lima uses x86_64/aarch64 in release names, so we use uname -m directly or map back if needed.
    # Since we normalized ARCH to amd64/arm64, we need to map for Lima if we use $ARCH, 
    # but the original code used $(uname -m) which works for Lima (x86_64/aarch64).
    # Let's keep using $(uname -m) for Lima for safety relative to release naming.
    VERSION=$(curl -fsSL https://api.github.com/repos/lima-vm/lima/releases/latest | jq -r .tag_name)
    curl -fsSL "https://github.com/lima-vm/lima/releases/download/${VERSION}/lima-${VERSION:1}-$(uname -s)-$(uname -m).tar.gz" | sudo tar Cxzvm /usr/local
    curl -fsSL "https://github.com/lima-vm/lima/releases/download/${VERSION}/lima-additional-guestagents-${VERSION:1}-$(uname -s)-$(uname -m).tar.gz" | sudo tar Cxzvm /usr/local
  fi
fi

# --- Kubectl Installation ---
echo "Checking kubectl installation..."
if command -v kubectl &>/dev/null; then
  echo "kubectl is already installed"
else
  echo "Installing kubectl..."
  if [[ $OS == "Darwin" ]]; then
     brew install kubectl
  elif [[ $OS == "Linux" ]]; then
     # Download the latest stable release using the detected ARCH (amd64/arm64)
     # kubectl release uses amd64/arm64
     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl"
     sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
     rm kubectl
  fi
fi

# --- OC Installation ---
echo "Checking oc installation..."
if command -v oc &>/dev/null; then
  echo "oc is already installed"
else
  echo "Installing oc..."
  if [[ $OS == "Darwin" ]]; then
     brew install openshift-cli
  elif [[ $OS == "Linux" ]]; then
     # Download oc client
     # Mirror: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/
     # Filenames: openshift-client-linux.tar.gz (amd64), openshift-client-linux-arm64.tar.gz (arm64)
     
     if [[ "$ARCH" == "amd64" ]]; then
       OC_TAR="openshift-client-linux.tar.gz"
     elif [[ "$ARCH" == "arm64" ]]; then
       OC_TAR="openshift-client-linux-arm64.tar.gz"
     fi
     
     curl -fsSL https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/$OC_TAR -o $OC_TAR
     sudo tar -C /usr/local/bin -xzf $OC_TAR oc
     rm $OC_TAR
  fi
fi

