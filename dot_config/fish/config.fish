# Homebrew (Apple Silicon)
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
end

# ターミナルの ANSI 青パレット(色4/12)を ayu の水色 #39BAE6 に差し替える(OSC 4)。
# macOS の ls は LSCOLORS の基本色しか使えないため、ls のディレクトリ色を
# プロンプトのパス色 (fish_prompt.fish の set_color 39BAE6) と揃えるにはパレット側を変えるしかない。
if status is-interactive
    printf '\e]4;4;rgb:39/ba/e6\a'   # blue
    printf '\e]4;12;rgb:39/ba/e6\a'  # bright blue
end
