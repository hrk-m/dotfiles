#!/bin/sh
if [ $(uname) != "Darwin" ] ; then
	echo "Not MacOS!"
	exit 0
fi


#######################################
# https://macos-defaults.com/ の設定
#######################################
# 確認したいもの
# https://zenn.dev/keyamin/articles/970af2dca9c4c5#%E3%81%9D%E3%81%AE%E4%BB%96
# https://github.com/nicknisi/dotfiles/blob/323694973dbb1628da879eee3387a138b1fc6b40/install.sh



## Keyborad
# キーリピートの反応速度を速くする
defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 17

# Dock & Menu Bar
echo "Dockを右に"
defaults write com.apple.dock "orientation" -string "right" && killall Dock
# 自動的に非表示にする。
defaults write com.apple.dock autohide -bool true  && killall Dock

## Finder
echo "Finder 内の隠しファイルを表示する"
defaults write com.apple.finder "AppleShowAllFiles" -bool "true" && killall Finder

# パスバーを表示
defaults write com.apple.finder "ShowPathbar" -bool "true" && killall Finder

for app in "Dock" \
	"Finder" \
	"SystemUIServer"; do
	killall "${app}" &> /dev/null
done
