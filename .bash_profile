# bashrc の読み込み
source ~/.bashrc

# PATH
export PATH=$HOME/.rbenv/bin:$PATH

# ruby
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# git
source /usr/local/etc/bash_completion.d/git-prompt.sh
source /usr/local/etc/bash_completion.d/git-completion.bash
GIT_PS1_SHOWDIRTYSTATE=true
# export PS1='\h\[\033[00m\]:\W\[\033[31m\]$(__git_ps1 [%s])\[\033[00m\]\$ '
export PS1='\[\033[32m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[31m\]$(__git_ps1)\[\033[00m\]\n\$ '

# ssh-agent
if [ -f "$HOME/.ssh/id_rsa" ]; then
  ssh-add -K "$HOME/.ssh/id_rsa" 2>/dev/null
fi
