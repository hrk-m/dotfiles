if [ $(uname) != "Darwin" ] ; then
	echo "Not MacOS!"
	exit 0
fi

# Dock
## Dockからすべてのアプリを消す
defaults write com.apple.dock persistent-apps -array
## Dockのサイズ
defaults write com.apple.dock "tilesize" -int "36"
## Dockを右に
defaults write com.apple.dock "orientation" -string "right"
## 自動的に非表示にする。
defaults write com.apple.dock autohide -bool true
## 最近起動したアプリを非表示
defaults write com.apple.dock "show-recents" -bool "false"
## アプリをしまうときのアニメーション
defaults write com.apple.dock "mineffect" -string "scale"
## 使用状況に基づいてデスクトップの順番を入れ替え
defaults write com.apple.dock "mru-spaces" -bool "false"
## Dock をリセット
killall Dock

# Screenshot
## 画像の影を無効化
defaults write com.apple.screencapture "disable-shadow" -bool "true"
## 保存場所
if [[ ! -d "$HOME/Pictures/Screenshots" ]]; then
    mkdir -p "$HOME/Pictures/Screenshots"
fi
defaults write com.apple.screencapture "location" -string "~/Pictures/Screenshots"
## 撮影時のサムネイル表示
defaults write com.apple.screencapture "show-thumbnail" -bool "false"
## 保存形式
defaults write com.apple.screencapture "type" -string "jpg"

# Finder
## 拡張子まで表示
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
## 隠しファイルを表示
defaults write com.apple.Finder "AppleShowAllFiles" -bool "true"
## パスバーを表示
defaults write com.apple.finder ShowPathbar -bool "true"
## 未確認ファイルを開くときの警告無効化
defaults write com.apple.LaunchServices LSQuarantine -bool "false"
## ゴミ箱を空にするときの警告無効化
defaults write com.apple.finder WarnOnEmptyTrash -bool "false"
## Finder をリセット
killall Finder

# Feedback
## フィードバックを送信しない
defaults write com.apple.appleseed.FeedbackAssistant "Autogather" -bool "false"
## クラッシュレポート無効化
defaults write com.apple.CrashReporter DialogType -string "none"

# .DS_Store
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool "true"
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool "true"

# Battery
## バッテリーを%表示
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Trackpad
## タップでクリック
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool "true"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool "true"
defaults -currentHost write -g com.apple.mouse.tapBehavior -bool "true"
## 軌跡の速さ
defaults write -g com.apple.trackpad.scaling 3
## スクロールの方向
defaults write -g com.apple.swipescrolldirection -bool "true"

# Mouse
## 軌跡の速さ
defaults write -g com.apple.mouse.scaling 3
## スクロールの速さ
defaults write -g com.apple.scrollwheel.scaling 5

# Keyboard
## キーのリピート速度
defaults write NSGlobalDomain KeyRepeat -int 1
## キーのリピート認識時間
defaults write NSGlobalDomain InitialKeyRepeat -int 17
## フルキーボードアクセスを有効化
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
## 本体キーボードのCapsLockキーの動作をControlにリマップ
keyboard_id="$(ioreg -c AppleEmbeddedKeyboard -r | grep -Eiw "VendorID|ProductID" | awk '{ print $4 }' | paste -s -d'-\n' -)-0"
defaults -currentHost write -g com.apple.keyboard.modifiermapping.${keyboard_id} -array-add "
<dict>
  <key>HIDKeyboardModifierMappingDst</key>\
  <integer>30064771300</integer>\
  <key>HIDKeyboardModifierMappingSrc</key>\
  <integer>30064771129</integer>\
</dict>
"

# Security
## ファイアウォールon
sudo defaults write /Library/Preferences/com.Apple.alf globalstate -int 1

# Others
## 自動で頭文字を大文字にしない
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool "false"
## スペルの訂正を無効にする
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool "false"

# TODO: 再起動したときに動いているか確認
# Update AppleSymbolicHotKeys settings
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 10 "{
    enabled = 1;
    value = {
        parameters = (65535, 96, 262144);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 11 "{
    enabled = 1;
    value = {
        parameters = (65535, 97, 262144);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 118 "{
    enabled = 0;
    value = {
        parameters = (65535, 18, 262144);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 119 "{
    enabled = 1;
    value = {
        parameters = (49, 18, 1048576);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 12 "{
    enabled = 1;
    value = {
        parameters = (65535, 122, 262144);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 120 "{
    enabled = 1;
    value = {
        parameters = (50, 19, 1048576);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 121 "{
    enabled = 1;
    value = {
        parameters = (51, 20, 1048576);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 122 "{
    enabled = 0;
    value = {
        parameters = (65535, 23, 262144);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 13 "{
    enabled = 1;
    value = {
        parameters = (65535, 98, 262144);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 15 "{
    enabled = 0;
    value = {
        parameters = (56, 28, 1572864);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 16 "{
    enabled = 0;
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 160 "{
    enabled = 0;
    value = {
        parameters = (65535, 65535, 0);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 17 "{
    enabled = 0;
    value = {
        parameters = (94, 24, 1572864);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 18 "{
    enabled = 0;
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 19 "{
    enabled = 0;
    value = {
        parameters = (45, 27, 1572864);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 20 "{
    enabled = 0;
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 21 "{
    enabled = 0;
    value = {
        parameters = (56, 28, 1835008);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 22 "{
    enabled = 0;
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 23 "{
    enabled = 0;
    value = {
        parameters = (165, 93, 1572864);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 24 "{
    enabled = 0;
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 25 "{
    enabled = 0;
    value = {
        parameters = (46, 47, 1835008);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 26 "{
    enabled = 0;
    value = {
        parameters = (44, 43, 1835008);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 27 "{
    enabled = 1;
    value = {
        parameters = (64, 33, 1048576);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 28 "{
    enabled = 1;
    value = {
        parameters = (51, 20, 1179648);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 29 "{
    enabled = 1;
    value = {
        parameters = (51, 20, 1441792);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 30 "{
    enabled = 1;
    value = {
        parameters = (52, 21, 1179648);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 31 "{
    enabled = 1;
    value = {
        parameters = (52, 21, 1441792);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 32 "{
    enabled = 1;
    value = {
        parameters = (65535, 53, 1048576);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 33 "{
    enabled = 1;
    value = {
        parameters = (65535, 125, 2359296);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 34 "{
    enabled = 1;
    value = {
        parameters = (65535, 53, 1179648);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 35 "{
    enabled = 1;
    value = {
        parameters = (65535, 125, 2490368);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 36 "{
    enabled = 0;
    value = {
        parameters = (65535, 122, 8388608);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 37 "{
    enabled = 1;
    value = {
        parameters = (65535, 122, 8519680);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 51 "{
    enabled = 1;
    value = {
        parameters = (64, 33, 1572864);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 52 "{
    enabled = 0;
    value = {
        parameters = (100, 2, 1572864);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 53 "{
    enabled = 1;
    value = {
        parameters = (65535, 107, 0);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 54 "{
    enabled = 1;
    value = {
        parameters = (65535, 113, 0);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 55 "{
    enabled = 1;
    value = {
        parameters = (65535, 107, 524288);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 56 "{
    enabled = 1;
    value = {
        parameters = (65535, 113, 524288);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 57 "{
    enabled = 1;
    value = {
        parameters = (65535, 100, 262144);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 59 "{
    enabled = 0;
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 "{
    enabled = 1;
    value = {
        parameters = (32, 49, 262144);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 "{
    enabled = 1;
    value = {
        parameters = (32, 49, 786432);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 62 "{
    enabled = 1;
    value = {
        parameters = (65535, 111, 0);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 63 "{
    enabled = 1;
    value = {
        parameters = (65535, 111, 131072);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "{
    enabled = 0;
    value = {
        parameters = (32, 49, 1048576);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 "{
    enabled = 1;
    value = {
        parameters = (65535, 49, 1572864);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 7 "{
    enabled = 1;
    value = {
        parameters = (65535, 120, 262144);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 70 "{
    enabled = 1;
    value = {
        parameters = (100, 2, 1310720);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 73 "{
    enabled = 1;
    value = {
        parameters = (65535, 53, 1048576);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 75 "{
    enabled = 0;
    value = {
        parameters = (65535, 100, 0);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 76 "{
    enabled = 0;
    value = {
        parameters = (65535, 100, 131072);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 "{
    enabled = 0;
    value = {
        parameters = (65535, 123, 8650752);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 8 "{
    enabled = 1;
    value = {
        parameters = (65535, 99, 262144);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 80 "{
    enabled = 1;
    value = {
        parameters = (65535, 123, 8781824);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 81 "{
    enabled = 0;
    value = {
        parameters = (65535, 124, 8650752);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 82 "{
    enabled = 1;
    value = {
        parameters = (65535, 124, 8781824);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 9 "{
    enabled = 1;
    value = {
        parameters = (65535, 118, 262144);
        type = standard;
    };
}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 98 "{
    enabled = 1;
    value = {
        parameters = (47, 44, 1179648);
        type = standard;
    };
}"