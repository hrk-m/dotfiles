# ghq 管理のリポジトリを fzf で選んで cd する(Ctrl+G にバインド。conf.d/keybindings.fish 参照)
function cd_git_repo -d "ghq list | fzf でリポジトリへ移動"
    set -l selected (ghq list | fzf)
    if test -n "$selected"
        cd (ghq root)/$selected
    end
    commandline -f repaint
end
