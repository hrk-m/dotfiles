# peco でコマンド履歴検索  ctr + r (検索履歴表示)
function fish_user_key_bindings
  bind \cr 'peco_select_history (commandline -b)'
end

# [ghq] git プロジェクト管理  ctr + g
set GHQ_SELECTOR peco

# ruby
eval (rbenv init - | source)

# MySQL
set -x PATH /usr/local/opt/mysql@5.6/bin $PATH

# PATH
set -x PATH ~/bin $PATH
set -x PATH /usr/local/bin $PATH
set -x PATH $HOME/.nodebrew/current/bin: $PATH

#################################
## alias 設定
#################################

# Directories
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias desk 'cd ~/Desktop'

# Git
alias g 'git'
alias add "git add"
alias commit "git commit"
alias checkout "git checkout"
alias branch "git branch"
alias push "git push"
alias pull "git pull"

alias ginit "git commit -m 'initial commit' --allow-empty"
alias gstash "git stash pop stash@{0}"
alias m "git checkout master"
alias mp "git checkout master && git pull"
alias dp "git checkout develop && git pull"
alias uncommit "git log -1 && git reset HEAD^1"
alias amend 'git commit --amend'

# tig
alias s 'tig status'
alias t 'tig'

# ディレクトリ確認
alias ls 'ls -a'
alias lp 'pwd && ls'

# rails
alias be 'bundle exec'
alias rs 'bundle exec rails s'
alias rc 'bundle exec rails c'
alias spec 'bundle exec rspec'

# Network Related
alias ip "ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ and print $1'"
