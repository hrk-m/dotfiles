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
brew install rbenv

brew install --cask iterm2
brew install --cask alfred
brew install --cask spectacle
brew install --cask clipy
brew install --cask appcleaner
brew install --cask visual-studio-code
brew install --cask google-chrome
brew install --cask atom
brew install --cask slack
brew install --cask docker
# brew install --cask homebrew/cask-versions/sequel-pro-nightly
# brew install --cask ngrok
# brew install --cask recordit
# brew install --cask tunnelblick
# brew install --cask dropbox
# brew install --cask libreoffice
# brew install --cask lastpass

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
