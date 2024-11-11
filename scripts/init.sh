#!/bin/bash
set -e

dir=$(dirname "${BASH_SOURCE[0]}")

stow -d $dir/.. -t $HOME

brew bundle install

$dir/mac-settings.sh

# registers additional bat themes/languages
bat cache --build
