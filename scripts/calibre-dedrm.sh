#!/bin/bash

dir=$(git rev-parse --show-toplevel)/.samignore/

gh release download -R https://github.com/noDRM/DeDRM_tools --pattern '*.zip' --clobber --output $dir/dedrm.zip

unzip -o $dir/dedrm.zip -d $dir/dedrm

calibre-customize --add $dir/dedrm/DeDRM_plugin.zip
calibre-customize --add $dir/dedrm/Obok_plugin.zip
