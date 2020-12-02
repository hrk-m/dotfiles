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

# git clone dotfile
cd ~/.
git clone git@github.com:hrk-m/dotfiles.git
cd dotfiles
