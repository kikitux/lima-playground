[ -f ./code ] || {
  curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-arm64' --output vscode_cli.tar.gz
  tar -xf vscode_cli.tar.gz
}

export KUBECONFIG=/var/lib/microshift/resources/kubeadmin/kubeconfig
./code tunnel
