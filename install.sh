#!/bin/sh

echo 'Setting up Mac...'

# install homebrew
if test ! $(which brew); then
  echo 'install homebrew'
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo '\nhomebrew already installed.'
fi

# Update Homebrew recipes
brew update

# Install Packages
brew install git
brew install tig

brew cask install iterm2
brew cask install alfred
brew cask install spectacle
brew cask install clipy
brew cask install appcleaner
brew cask install visual-studio-code
brew cask install google-chrome
brew cask install atom
brew cask install slack
brew cask install docker
# brew cask install homebrew/cask-versions/sequel-pro-nightly
# brew cask install ngrok
# brew cask install recordit
# brew cask install tunnelblick
# brew cask install dropbox
# brew cask install libreoffice

brew cleanup
brew cask cleanup

# git clone dotfile
mkdir ~/src/github.com/hrk-m
cd ~/src/github.com/hrk-m
git clone git@github.com:hrk-m/dotfiles.git

# Display hidden files / folders
echo "Display hidden files / folders"
defaults write com.apple.finder AppleShowAllFiles TRUE
killall Finder
