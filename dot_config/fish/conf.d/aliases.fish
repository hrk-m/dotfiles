# zsh(.zshrc)から移植した alias。zsh の alias 同様、対話シェルでのみ定義する
# (スクリプト実行時に add / commit 等が git を握らないようにするため)
if status is-interactive
    # AI コミット
    alias aic 'aicommit -c "https://qiita.com/itosho/items/9565c6ad2ffc24c09364 を参考にコミットメッセージを作成してください。日本語で答えて。また参照したQiitaの記事のことは触れないでください。コミットタイプは以下を使用してください: fix:バグ修正、add:新規(ファイル)機能追加、update:機能修正(バグではない)、remove:削除(ファイル)" -d'

    # ディレクトリ移動
    alias .. 'cd ..'
    alias ... 'cd ../..'
    alias .... 'cd ../../..'
    alias ..... 'cd ../../../..'
    alias desk 'cd ~/Desktop'

    # 表示(自己参照 alias は fish が自動で command ls に変換する)
    alias ls 'ls -a'
    alias lp 'pwd && ls'

    # エディタ(カレントディレクトリを開く)
    alias code 'code .'
    alias c 'cursor .'
    alias cursor 'cursor .'

    # git
    alias g git
    alias add 'git add'
    alias commit 'git commit'
    alias checkout 'git checkout'
    alias branch 'git branch'
    alias push 'git push'
    alias pull 'git pull'
    alias ginit 'git commit -m "initial commit" --allow-empty'
    alias gstash "git stash pop 'stash@{0}'"
    alias m 'git checkout master'
    alias mp 'git checkout master && git pull'
    alias mmp 'git checkout main && git pull'
    alias dp 'git checkout develop && git pull'
    alias uncommit 'git log -1 && git reset HEAD^1'
    alias amend 'git commit --amend'

    # tig
    alias s 'tig status'
    alias t tig

    # Ruby
    alias be 'bundle exec'
    alias rs 'bundle exec rails s'
    alias rc 'bundle exec rails c'
    alias spec 'bundle exec rspec'

    # Network
    alias ip 'ifconfig -a | perl -nle\'/(\d+\.\d+\.\d+\.\d+)/ && print $1\''
end
