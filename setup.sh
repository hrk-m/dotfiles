#!/bin/sh
USER=$(id -u)
DOTFILES=$HOME/src/github.com/hrk-m/dotfiles

echo "Set a blazingly fast keyboard repeat rate"
defaults write -g KeyRepeat -int 1

echo "Set a shorter Delay until key repeat"
defaults write -g InitialKeyRepeat -int 17

echo "Dockを右に"
defaults write com.apple.dock "orientation" -string "left" && killall Dock

echo "Finder 内の隠しファイルを表示する"
defaults write com.apple.finder "AppleShowAllFiles" -bool "true" && killall Finder

# パスバーを表示
defaults write com.apple.finder "ShowPathbar" -bool "true" && killall Finder
