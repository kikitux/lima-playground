
echo checking if lima is installed
brew list lima lima-additional-guestagents &>/dev/null || {
  brew update
  brew upgrade
  echo installing lima
  brew install lima lima-additional-guestagents
}

