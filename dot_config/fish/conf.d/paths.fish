# zsh(.zshrc)から移植した PATH と環境変数
# fish_add_path -g: セッション毎に conf.d から組み立てる(universal 変数に永続化しない)。
# 存在しないディレクトリを渡しても安全で、重複追加もされない
fish_add_path -g ~/bin ~/.local/bin ~/go/bin ~/.bun/bin ~/.maestro/bin ~/.antigravity/antigravity/bin

# Android SDK
set -gx ANDROID_HOME $HOME/Library/Android/sdk
fish_add_path -g $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools
