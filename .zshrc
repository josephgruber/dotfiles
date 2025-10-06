# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# Allow directory stacks
setopt AUTO_PUSHD       # Push the old directory onto a stack
setopt PUSHD_MINUS      # Swap the directory stack ordering

# Setup autocompletion
zstyle ':completion:*' completer _expand _complete _ignored _correct
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
autoload -U bashcompinit
bashcompinit
autoload -U compinit
compinit

# Set zsh history file length
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000 # current session's history limit
SAVEHIST=50000 # zsh saves this many lines from the in-memory history list to the history file upon shell exit
HISTORY_IGNORE="(ls|cd|pwd|exit|cd|clear)*"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY # history file is updated immediately after a command is entered
setopt SHARE_HISTORY # allows multiple Zsh sessions to share the same command history
setopt EXTENDED_HISTORY # records the time when each command was executed along with the command itself
setopt APPENDHISTORY # ensures that each command entered in the current session is appended to the history file immediately after execution

# Global environment variables
export AWS_PAGER=
export BLOCKSIZE=1k
export BUILDAH_FORMAT=docker
export DEFAULT_USER=$(whoami)
export DOTFILES="$HOME/.dotfiles"
export EDITOR="code --wait"
export HOMEBREW_NO_ENV_HINTS=1
export PODMAN_COMPOSE_WARNING_LOGS=false
export SSH_AUTH_SOCK="~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock"
export VISUAL="$EDITOR"

# Global aliases
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

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND="fd --type f"
# export FZF_DEFAULT_COMMAND='ag --hidden -g ""'

# Setup and configure Node.js Version Manager (NVM)
if [ -d "$HOME/.nvm" ] ; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi

# Custom shell completions
complete -C '/opt/homebrew/bin/aws_completer' aws
complete -C '/opt/homebrew/bin/aws_completer' awslocal
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Custom functions
chpwd() { ls -l --color=auto; }

# Setup and configure pyenv
if [ -d "$HOME/.pyenv" ] ; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - zsh)"
fi

# iTerm2 shell integration
[[ "$TERM_PROGRAM" == "iTerm.app" ]] && zstyle :omz:plugins:iterm2 shell-integration yes

# Setup and configure direnv
eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT=$'\033[2mdirenv: %s\033[0m'

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# VSCode Integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-rc.zsh"

# Initialize oh-my-posh with a custom theme
eval $(oh-my-posh init zsh --config "$DOTFILES/themes/oh-my-posh.json")

# Local Overrides
[ -f "${DOTFILES}/.local/.zshrc" ] && source "${DOTFILES}/.local/.zshrc"

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
