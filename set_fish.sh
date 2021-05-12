# Install fish peco ghq
brew install fish
brew install peco
brew install ghq

echo 'install fish shell'
### fish, ghq, peco の設定 (https://qiita.com/naname/items/00d4c81a98c017b0fb43)
# Install fisher(fisherman)
curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
# Install oh-my-fish/plugin-peco
echo 'install peco'
fisher install oh-my-fish/plugin-peco

# Install decors/fish-ghq
echo 'install ghq'
fisher install decors/fish-ghq
# ghq で管理するディレクトリの設定(src で管理)
mkdir ~/src
git config --global ghq.root ~/src

# 切り替わらなければ、sudo vi /etc/shellsの末尾に /usr/local/bin/fish を追加
echo 'Set default shell to fish'
chsh -s $(which fish)
source ~/.config/fish/config.fish # fish 設定反映 (ghq がsource で読み込まないと動作しない)
