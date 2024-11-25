#!/bin/bash

root=$(git rev-parse --show-toplevel)

brew bundle --file $root/exclude/Brewfile

$root/scripts/mac-settings.sh

git submodule update --init --remote

# registers additional bat themes/languages
bat cache --build

# install/start skhd (may need a computer restart)
skhd --install-service
skhd --start-service

# install asdf tools
cat .tool-versions | cut -d' ' -f1 | grep "^[^\#]" | xargs -I {} asdf plugin add  {}
asdf install

$root/scripts/calibre-dedrm.sh
