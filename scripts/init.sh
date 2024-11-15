#!/bin/bash
dir=$(dirname "${BASH_SOURCE[0]}")

brew bundle --file $dir/../exclude/Brewfile

$dir/mac-settings.sh

git submodule init
git submodule update

# registers additional bat themes/languages
bat cache --build

# install/start skhd (may need a computer restart)
skhd --install-service
skhd --start-service

# install asdf tools
cat .tool-versions | cut -d' ' -f1 | grep "^[^\#]" | xargs -I {} asdf plugin add  {}
asdf install
