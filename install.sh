#!/bin/sh

echo 'Setting up Mac...'

# install xcode
if [[ "$(xcode-select -p)" == "" ]]; then
  echo '\nInstalling Xcode '
  xcode-select --install
  echo 'Done'
else
  echo '\nXcode already installed.'
fi

# install homebrew
if test ! $(which brew); then
  echo 'install homebrew'
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo '\nhomebrew already installed.'
fi
# Update Homebrew recipes
brew update
# Move Brewfile into place
ln -fs $(pwd)/Brewfile ~/
# Install all our dependencies with bundle (See Brewfile)
brew bundle
brew cleanup
brew cask cleanup

# Display hidden files / folders
echo "Display hidden files / folders"
defaults write com.apple.finder AppleShowAllFiles TRUE
killall Finder

echo 'install fish shell'
### fish, ghq, peco の設定 (https://qiita.com/naname/items/00d4c81a98c017b0fb43)
# Install fisher(fisherman)
curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
# Install oh-my-fish/plugin-peco
echo 'install peco'
fisher add oh-my-fish/plugin-peco

# Install decors/fish-ghq
echo 'install ghq'
fisher add decors/fish-ghq
# ghq で管理するディレクトリの設定(src で管理)
mkdir ~/src && git config --global ghq.root ~/src

# 切り替わらなければ、sudo vi /etc/shellsの末尾に /usr/local/bin/fish を追加
echo 'Set default shell to fish'
chsh -s $(which fish)
source ~/.config/fish/config.fish # fish 設定反映 (ghq がsource で読み込まないと動作しない)

# git clone dotfile
mkdir ~/src/github.com/hrk-m
cd ~/src/github.com/hrk-m
git clone git@github.com:hrk-m/dotfiles.git
