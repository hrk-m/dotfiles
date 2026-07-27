echo '#############################################################################################'
# git
echo 'git 設定'
git --version
ln -fs $(pwd)/git/.gitconfig ~/
ln -fs $(pwd)/git/.gitignore_global ~/
echo '#############################################################################################'

# bash
echo 'bash 設定'
ln -fs $(pwd)/.bash_profile ~/
ln -fs $(pwd)/.bashrc ~/
echo '#############################################################################################'

# vim
echo 'vim 設定'
ln -fs $(pwd)/vim/.vimrc ~/
echo '#############################################################################################'

# VS Code
echo "VS Code 設定"
mkdir -p ~/Library/Application\ Support/Code/User/
ln -fs $(pwd)/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
ln -fs $(pwd)/vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
echo '#############################################################################################'
