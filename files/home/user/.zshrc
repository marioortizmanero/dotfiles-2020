###### CONFIG ######
# Basic config
HIST_STAMPS="dd/mm/yyyy"
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt +o nomatch
setopt hist_ignore_all_dups


###### BINDINGS ######
# Vi mode with some vim-like tweaks
bindkey -v
export KEYTIMEOUT=1
bindkey "^?" backward-delete-char  # vim-like behaviour for backspace
bindkey "^R" history-incremental-search-backward  # restore search binding
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char 


###### PLUGINS & THEMES ######
# Pure prompt
autoload -Uz promptinit; promptinit
prompt pure


###### ENV ######
# Other directories with binaries
export PATH="$PATH:$HOME/Files/dotfiles/bin"

# Useful variables
export PRIVATE_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')

# Fixes some Java apps on tiling window managers
export _JAVA_AWT_WM_NONREPARENTING=1

# Configuration for the editor
export VISUAL=nvim
export EDITOR=nvim


###### RUST CONFIG ######
export CARGO_TARGET_DIR="$HOME/.cache/cargo"


###### NNN CONFIG ######
# Use editor by default, auto set-up temporary NNN_FIFO
export NNN_OPTS="ea"
# Use trash instead of removing completely
export NNN_TRASH=1
# Plugins: preview, drag and drop
export NNN_PLUG='t:preview-tui;d:dragdrop'
# For the preview-tui script
export USE_PISTOL=1
# Saving the directory on exit
n () {
    # Block nesting of nnn in subshells
    if [ -n "$NNNLVL" ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi

    # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Preview will be launched automatically (-P). Use selection when
    # available (-u).
    nnn -u -P t "$@"

    if [ -f "$NNN_TMPFILE" ]; then
        source "$NNN_TMPFILE"
        rm -f "$NNN_TMPFILE" > /dev/null
    fi
}


###### ALIAS & CUSTOM FUNCTIONS ######
# Shortcuts
alias :q="exit"
alias :wq="exit"
alias adb-restart="sudo adb kill-server && sudo adb start-server"
alias clang-format-custom="clang-format -i --style='{IndentWidth: 4, BasedOnStyle: Google}'"
alias clone='alacritty --working-directory "$PWD" -e sh -c "ls; zsh" &!'
alias cmake-debug="cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -DBUILD_TESTING=YES"
alias cmake-release="cmake -DCMAKE_BUILD_TYPE=Release"
alias flake8-custom="flake8 --ignore='F821,W503,E731'"
alias getpid="xprop _NET_WM_PID | cut -d' ' -f3"
alias gitlog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gitreset="git add -A; git reset --hard"
alias hugo-net="hugo server --bind=$PRIVATE_IP --baseURL=http://$PRIVATE_IP:1313"
alias nuke="killall -s SIGKILL"
alias py="python3"
alias pylint-custom="pylint --disable import-error --disable missing-module-docstring --disable missing-class-docstring --disable missing-function-docstring --disable attribute-defined-outside-init --disable invalid-name"
alias pymake="python3 setup.py sdist bdist_wheel"
alias quitsession="kill -9 -1"
alias rm="trash"
alias sizes="du -cha --max-depth=1 2>/dev/null | sort -rh | less"
alias vim="nvim"

# Default flags for compatibility and such
alias diff="diff --color=auto"
alias egrep="egrep --color=auto"
alias grep="grep --color=auto"
alias less="less -R"
alias ls="ls -A --color"
alias rg='rg --hidden'

# Configuration files
alias bspwmconf="$EDITOR ~/.config/bspwm/bspwmrc"
alias dunstconf="$EDITOR ~/.config/dunst/dunstrc"
alias keysconf="$EDITOR ~/.config/sxhkd/sxhkdrc"
alias alacrittyconf="$EDITOR ~/.config/alacritty/alacritty.yml"
alias lightdmconf="sudo $EDITOR /etc/lightdm/lightdm-webkit2-greeter.conf"
alias lightdmwebkitconf="sudo $EDITOR /usr/share/lightdm-webkit/themes"
alias picomconf="$EDITOR ~/.config/picom/picom.conf"
alias pistolconf="$EDITOR ~/.config/pistol/pistol.conf"
alias polyconf="$EDITOR ~/.config/polybar/config"
alias polyinitconf="$EDITOR ~/.config/polybar/launch.sh"
alias roficonf="$EDITOR ~/.config/rofi/arch.rasi"
alias vidifyconf="$EDITOR ~/.config/vidify/config.ini"
alias vimconf="$EDITOR ~/.config/nvim/init.vim"
alias xprofileconf="$EDITOR ~/.xprofile"
alias zathuraconf="$EDITOR ~/.config/zathura/zathurarc"
alias zshconf="$EDITOR ~/.zshrc"

# Programs
alias android-studio="/opt/android-studio/bin/studio.sh"
alias xampp="sudo /opt/lampp/lampp start"

# Tools for pipes
alias fromclip="xsel --clipboard -o"
alias toclip="xsel --clipboard -i"
alias toixio="curl -F 'f:1=<-' ix.io | tee -a ~/.paste_history"


# ZSH Syntax Highlighting goes at the end
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
