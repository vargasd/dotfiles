#!/bin/bash

# TODO choose between this and ../exclude/RectangleConfig.json
defaults write com.knollsoft.Rectangle almostMaximizeHeight -float 0.75
defaults write com.knollsoft.Rectangle almostMaximizeWidth -float 0.6

# make the dock not invasive
defaults write com.apple.dock "autohide" -bool "true"
defaults write com.apple.dock "tilesize" -int "16" 

# disable diacritics menu
defaults write -g ApplePressAndHoldEnabled -bool false

# open on play/pause
# defaults write digital.twisted.noTunes replacement /Applications/Deezer.app       
