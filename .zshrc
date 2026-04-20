eval "$(brew shellenv)"

# Allow directory stacks
setopt AUTO_PUSHD       # Push the old directory onto a stack
setopt PUSHD_MINUS      # Swap the directory stack ordering

# Setup autocompletion
autoload -Uz compinit
compinit

# Custom shell completions
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
eval "$(ruff generate-shell-completion zsh)"

# Docker completions
if [ -d "$HOME/.docker" ] ; then
    fpath=($HOME/.docker/completions $fpath)
fi

# Autocompletion settings and configuration
unsetopt MENU_COMPLETE
setopt AUTO_MENU
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' completer _complete _ignored
zstyle ':completion:*' insert-tab false # Trigger completion immediately even without a space
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Enable case-insensitive Tab search
zstyle ':completion:*' menu select
zstyle ':completion:*' substitute off
zstyle ':completion:*' use-cache on
zstyle ':completion:*:descriptions' format '[%d]'

# Initialize fzf-tab
source $HOMEBREW_PREFIX/share/fzf-tab/fzf-tab.zsh

# fzf-tab previews and styles
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' fzf-flags --bind=ctrl-/:toggle-preview
zstyle ':fzf-tab:*' group-colors $'\033[34m' $'\033[35m' $'\033[36m' $'\033[31m' $'\033[32m' $'\033[33m'
zstyle ':fzf-tab:*' fzf-bindings 'tab:accept'
zstyle ':fzf-tab:*' accept-multiple-contents true
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --line-range :500 $realpath'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'git log --color=always --oneline --graph --date=short $word'

# Bash compatibility
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/opt/homebrew/bin/aws_completer' aws
complete -C '/opt/homebrew/bin/aws_completer' awslocal

# Ensure LS_COLORS is set (for fzf-tab colors)
if command -v dircolors > /dev/null; then
  eval "$(dircolors -b)"
else
  export LS_COLORS="di=1;34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
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
export PYTHONSTARTUP=$DOTFILES/config/python/startup.py
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

# Initialize zoxide
eval "$(zoxide init zsh)"

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"
export FZF_DEFAULT_COMMAND="fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"

export FZF_DEFAULT_OPTS="
  --prompt='λ '
  --pointer='▶'
  --marker='✓'
  --height 40%
  --layout=reverse
  --border
  --info=inline
  --header '⌃T: Files | ⌥C: Dirs | ⌃R: History'
  --color='header:italic:underline,fg+:cyan'"

export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# Preview for Alt+C (Directory tree)
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'tree -C {} | head -200'"

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

# Custom functions
if [[ -z "$CLAUDECODE" ]]; then
    chpwd() { ls; }
fi

gb() {
  git branch -a --color=always | grep -v '/HEAD' | \
  fzf --height 40% --ansi --multi --preview-window right:70% \
      --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%h %ad %s" $(sed "s/.* //" <<< {}) | head -n 20' | \
  sed "s/.* //" | xargs git checkout
}

fga() {
  local files
  # -m allows multi-select with Tab
  files=$(git status -s | fzf -m --ansi --preview 'git diff --color=always {2}' | awk '{print $2}')
  if [ -n "$files" ]; then
    echo "$files" | xargs git add
    echo "Staged: $files"
  fi
}

fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}

# Setup and configure pyenv (lazy-loaded to avoid lock issues)
if [ -d "$HOME/.pyenv" ] ; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PIPENV_VENV_IN_PROJECT=1 # Create virtualenvs inside the project directory
    export PIPENV_VERBOSITY=-1
    export PIPENV_PYTHON=$PYENV_ROOT/shims/python
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

# Setup and configure direnv (exclude Claude Code terminals)
if [[ -z "$CLAUDECODE" ]]; then
    eval "$(direnv hook zsh)"
    export DIRENV_LOG_FORMAT=$'\033[2mdirenv: %s\033[0m'
fi

# Load zsh-autosuggestions
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Load zsh-fast-syntax-highlighting and theme
source $DOTFILES/themes/zsh-syntax-highlighting.sh
source $HOMEBREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# VSCode Integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-rc.zsh"

# Initialize oh-my-posh with a custom theme
eval "$(oh-my-posh init zsh --config "$DOTFILES/themes/oh-my-posh.json")"

# Local Overrides. Keep at the bottom of this file.
[ -f "${DOTFILES}/.local/.zshrc" ] && source "${DOTFILES}/.local/.zshrc"
