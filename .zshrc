eval "$(brew shellenv)"

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
# Only check compinit cache once per day
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

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
export DEFAULT_USER="$USER"
export DOTFILES="$HOME/.dotfiles"
export EDITOR="code --wait"
export HOMEBREW_NO_ENV_HINTS=1
export PODMAN_COMPOSE_WARNING_LOGS=false
export PYTHONSTARTUP=$DOTFILES/python/startup.py
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
export VISUAL="$EDITOR"

# Global aliases
alias cp="cp -iv"
alias edit="code --wait"
alias git_prune="git fetch --prune && git branch -vv | grep 'origin/.*: gone]' | awk '{print \$1}' | xargs git branch -d"
alias gsm="git switch main && git fetch"
alias ld="lazydocker"
alias lg="lazygit"
alias ls="eza -1 --color=auto --classify --group-directories-first --icons --git" # ls
alias mkdir="mkdir -pv"
alias mv="mv -iv"
alias mwps="git push -u origin -o merge_request.create -o merge_request.target=master -o merge_request.merge_when_pipeline_succeeds"
alias rm="rm -iv"
alias untar="tar -zxvf"
alias which="which -a"

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"
export FZF_DEFAULT_COMMAND="fd --type f"
# export FZF_DEFAULT_COMMAND='ag --hidden -g ""'

# Setup and configure Node.js Version Manager (NVM) via lazy load
if [ -d "$HOME/.nvm" ] ; then
    export NVM_DIR="$HOME/.nvm"
    export PATH="$NVM_DIR/versions/node/$(cat $NVM_DIR/alias/default 2>/dev/null || echo 'system')/bin:$PATH"
    # Lazy load nvm when needed
    nvm() {
        unset -f nvm
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        nvm "$@"
    }
fi

# Custom shell completions
complete -C '/opt/homebrew/bin/aws_completer' aws
complete -C '/opt/homebrew/bin/aws_completer' awslocal
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Custom functions
chpwd() { ls -l --color=auto; }

# Setup and configure pyenv (lazy-loaded to avoid lock issues)
if [ -d "$HOME/.pyenv" ] ; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    # Lazy load pyenv
    pyenv() {
        unset -f pyenv
        eval "$(command pyenv init - zsh)"
        pyenv "$@"
    }
fi

# iTerm2 shell integration
[[ "$TERM_PROGRAM" == "iTerm.app" ]] && zstyle :omz:plugins:iterm2 shell-integration yes

# Setup and configure direnv
eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT=$'\033[2mdirenv: %s\033[0m'

# Cache brew prefix to avoid subprocess
BREW_PREFIX="/opt/homebrew"
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# VSCode Integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-rc.zsh"

# Initialize oh-my-posh with a custom theme
eval "$(oh-my-posh init zsh --config "$DOTFILES/themes/oh-my-posh.json")"

# Local Overrides. Keep at the bottom of this file.
[ -f "${DOTFILES}/.local/.zshrc" ] && source "${DOTFILES}/.local/.zshrc"
