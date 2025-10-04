# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# Allow directory stacks
setopt AUTO_PUSHD       # Push the old directory onto a stack
setopt PUSHD_MINUS      # Swap the directory stack ordering

DEFAULT_USER=$(whoami)

# Set zsh history file length
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

# --------------------- #
# Environment Variables #
# --------------------- #\
export AWS_PAGER=
export BLOCKSIZE=1k
export BUILDAH_FORMAT=docker
export EDITOR="code --wait"
export HOMEBREW_NO_ENV_HINTS=1
export PODMAN_COMPOSE_WARNING_LOGS=false
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
export VISUAL="$EDITOR"

# ------------------ #
# Source Other Files #
# ------------------ #
zstyle :omz:plugins:iterm2 shell-integration yes # iTerm2 shell integration

eval $(/opt/homebrew/bin/brew shellenv)


# ------- #
# Aliases #
# ------- #
alias cp="cp -iv"
alias docker="podman"
alias docker-compose="podman-compose"
alias edit="code --wait"
alias git_prune="git fetch --prune && git branch -vv | grep 'origin/.*: gone]' | awk '{print \$1}' | xargs git branch -d"
alias gsm="git switch main && git fetch"
alias ld="lazydocker"
alias lg="lazygit"
alias ls="eza -1 --color=auto --classify --group-directories-first --icons" # ls
alias mkdir="mkdir -pv"
alias mv="mv -iv"
alias mwps="git push -u origin -o merge_request.create -o merge_request.target=master -o merge_request.merge_when_pipeline_succeeds"
alias rm="rm -iv"
alias untar="tar -zxvf"
alias which="which -a"

# -------------------------- #
# Node Version Manager (NVM) #
# -------------------------- #
if [ -d "$HOME/.nvm" ] ; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi

# ----------------- #
# Shell Completions #
# ----------------- #
zstyle ':completion:*' completer _expand _complete _ignored _correct
autoload -U bashcompinit
bashcompinit
autoload -U compinit
compinit

complete -C '/opt/homebrew/bin/aws_completer' aws
complete -C '/opt/homebrew/bin/aws_completer' awslocal
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ---------------- #
# Custom Functions #
# ---------------- #
chpwd() { ls -l --color=auto; }

# ----- #
# Pyenv #
# ----- #
if [ -d "$HOME/.pyenv" ] ; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - zsh)"
fi

# ---------------- #
# Direnv Settings #
# ---------------- #
export DIRENV_LOG_FORMAT=$'\033[2mdirenv: %s\033[0m'
eval "$(direnv hook zsh)"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# VSCode Integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-rc.zsh"

eval "$(oh-my-posh init zsh --config '/Users/josephgruber/.dotfiles/themes/oh-my-posh.json')"

# Local Overrides
[ -f "${HOME}/.dotfiles/.local/.zshrc" ] && source "$HOME/.dotfiles/.local/.zshrc"

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
