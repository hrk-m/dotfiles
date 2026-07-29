# fzf の標準キーバインドを有効化する
#   Ctrl+R: 履歴検索 / Ctrl+T: ファイル名挿入 / Alt+C: ディレクトリ移動
if status is-interactive; and command -q fzf
    fzf --fish | source
end
