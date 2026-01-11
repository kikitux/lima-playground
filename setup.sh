#!/bin/env bash

SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO="sudo"

OS=$(uname)
ARCH=$(uname -m)
case "$ARCH" in
  x86_64|amd64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

echo "Detected OS: $OS, Arch: $ARCH"

# --- curl jq Installation ---
echo "Checking curl and jq installation..."

for bin in curl jq; do
  if ! command -v "$bin" &>/dev/null; then
    missing=true
    break
  fi
done

if [ "${missing:-false}" = false ]; then
  echo "curl and jq are already installed"
else
  case "$OS" in
    Darwin)
      echo "Installing curl and jq via Homebrew..."
      brew update
      brew upgrade
      brew install curl jq
      ;;
    Linux)
      if command -v dnf &>/dev/null; then
        echo "Installing curl and jq via dnf..."
        $SUDO dnf install -y curl jq

      elif command -v apt-get &>/dev/null; then
        echo "Installing curl and jq via apt..."
        $SUDO apt-get update
        $SUDO apt-get install -y curl jq

      else
        echo "No supported package manager found" >&2
        exit 1
      fi
      ;;
    *)
      echo "Unsupported OS: $OS" >&2
      exit 1
      ;;
  esac
fi

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
    VERSION=$(curl -fsSL https://api.github.com/repos/lima-vm/lima/releases/latest | jq -r .tag_name)
    curl -fsSL "https://github.com/lima-vm/lima/releases/download/${VERSION}/lima-${VERSION:1}-$(uname -s)-$(uname -m).tar.gz" | $SUDO tar Cxzvm /usr/local
    curl -fsSL "https://github.com/lima-vm/lima/releases/download/${VERSION}/lima-additional-guestagents-${VERSION:1}-$(uname -s)-$(uname -m).tar.gz" | $SUDO tar Cxzvm /usr/local
  fi
fi

# --- qemu-system-x86_64 Installation ---
if [[ $OS == "Linux" ]]; then
  echo "Checking qemu-system-x86_64 installation..."
  if command -v qemu-system-x86_64 &>/dev/null; then
    echo "qemu-system-x86_64 is already installed"
  else
    which dnf &>/dev/null && $SUDO dnf install -y qemu-system-x86_64
    which apt &>/dev/null && $SUDO apt-get update && $SUDO apt-get install -y qemu-system
  fi
fi

# --- qemu-system-aarch64 Installation ---
if [[ $OS == "Linux" ]]; then
  echo "Checking qemu-system-aarch64 installation..."
  if command -v qemu-system-aarch64 &>/dev/null; then
    echo "qemu-system-aarch64 is already installed"
  else
    which dnf &>/dev/null && $SUDO dnf install -y qemu-system-aarch64
    which apt &>/dev/null && $SUDO apt-get update && $SUDO apt-get install -y qemu-system
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
     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl"
     $SUDO install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
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
     if [[ "$ARCH" == "amd64" ]]; then
       OC_TAR="openshift-client-linux.tar.gz"
     elif [[ "$ARCH" == "arm64" ]]; then
       OC_TAR="openshift-client-linux-arm64.tar.gz"
     fi

     curl -fsSL https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/$OC_TAR -o $OC_TAR
     $SUDO tar -C /usr/local/bin -xzf $OC_TAR oc
     rm $OC_TAR
  fi
fi

