#copy from http://www.pixelbeat.org/settings/.bashrc
# .bashrc

# User specific aliases and functions

# Settings in this file are only for interactive shells.
# I don't know why bash loads this file for scp etc.,
# but return if that's the case.
[ "$PS1" ] || return

# Source global definitions
[ -f /etc/bashrc ] && . /etc/bashrc

#######################################
# user specific environment
#######################################

# for mc, cvs, svn, ...
export EDITOR=vim

# Use vim to browse man pages. One can use Ctrl-[ and Ctrl-t
# to browse and return from referenced man pages. ZZ or q to quit.
# Note initially within vim, one can goto the man page for the
# word under the cursor by using [section_number]K.
# Note we use bash explicitly here to support process substitution
# which in turn suppresses the "Vim: Reading from stdin..." warning.
export MANPAGER='bash -c "vim -MRn -c \"set ft=man nomod nolist nospell nonu\" \
-c \"nm q :qa!<CR>\" -c \"nm <end> G\" -c \"nm <home> gg\"</dev/tty <(col -b)"'
# GROFF_NO_SGR is required with man-db which uses grotty to
# output SGR codes by default when attached to a terminal.
# We want vim to highlight the raw text, so disable that feature.
# Also see MANPAGER in my .vimrc for extra handling to support
# ctrl-[ with man-db
export GROFF_NO_SGR=1
# Another option is to use $VIMRUNTIME/macros/less.sh
# though I find that less effective

# vim and gnome-terminal have support for 256 colours in fedora 8 at least
# Note older debian/ubuntu users need to install the ncurses-term package.
# Note this should be set in ~/.profile for Fedora startup scripts to
# setup LS_COLORS correctly.
# export TERM=xterm-256color

#######################################
# change app defaults
# Note one can disable an alias for a
# command by running like \command
#######################################

# highlight $HOST:$PWD prompt
PS1='\[\e[1m\]\h:\w\$\[\e[0m\] '

# Don't store duplicate adjacent items in the history
HISTCONTROL=ignoreboth

# adjust settings according to current terminal window width
# which may have changed while the last command was running
# (which is a common occurance for vim/less/etc.)
# Note this is already set in /etc/bashrc on Fedora 8 at least.
shopt -s checkwinsize

# GREP_COLOR=bright yellow on black bg.
# use GREP_COLOR=7 to highlight whitespace on black terminals
# LANG=C for speed. See also: http://www.pixelbeat.org/scripts/findrepo
alias grep='GREP_COLOR="1;33;40" LANG=C grep --color=auto'
alias ls="BLOCK_SIZE=\'1 ls --color=auto" #enable thousands grouping and colour
alias minicom='minicom -c on' #enable colour
alias cal='cal -3' #show 3 months by default
alias units='units -t' #terse mode
alias diff='LC_ALL=C TZ=GMT0 diff -Naur' #normalise diffs for distribution
alias lynx='lynx -force_html -width=$COLUMNS' #best settings for viewing HTML
alias links='links -force-html' #need to enable colour in config menu manually
alias xterm='xterm -fb "" -bg black -fg gray -fa "Sans Mono" -fs 9 +sb -sl 3000 -g 80x50+1+1'
#alias sudo='sudo env PATH=$PATH' #work around sudo built --with-secure-path (ubuntu)
alias vim='vim -X' #don't try to contact xserver (which can hang on network issues)
#alias gdb='gdb -tui -quiet' #enable the text window interface if possible
alias head='head -n $((${LINES:-12}-2))' #as many as possible without scrolling
alias tail='tail -n $((${LINES:-12}-2)) -s.1' #Likewise, also more responsive -f
alias mplayer='mplayer -msglevel all=-1:statusline=5:cplayer=5' #less verbose
alias clip='xclip -selection c' #update the main clipboard
alias virtualbox='VBOX_GUI_DBG_ENABLED=1 virtualbox'
# Tell less to display colours, and use smartcase searching
# Also don't wrap lines, as less supports horizontal scolling
# Note setting Q to use the visible bell, may cause delays.
export LESS="-RSi"
# Adjust the less highlight colors
export LESS_TERMCAP_so="$(printf 'rev\nbold\nsetaf 3\n' | tput -S)"
export LESS_TERMCAP_se="$(tput sgr0)"

#######################################
# shortcut aliases and functions
#######################################

alias ..="cd .."        #go to parent dir
alias ...="cd ../.."    #go to grandparent dir
alias -- -="cd -"       #go to previous dir
alias l='ls'
alias l.='ls -d .*'     #list hidden files
alias ll='ls -lhrt'     #extra info compared to "l"
alias lld='ls -lUd */'  #list directories
alias lss='l --color=always | less'   #colored "l" with less(1)

# what most people want from od (hexdump)
alias hd='od -Ax -tx1z -v'

# canonicalize path (including resolving symlinks)
realpath . >/dev/null 2>&1 || alias realpath='readlink -f'

# make and change to a directory
md () { mkdir -p "$1" && cd "$1"; }

# quick plot of numbers on stdin. Can also pass plot params.
# E.G: seq 1000 | sed 's/.*/s(&)/' | bc -l | plot linecolor 2
plot() { { echo 'plot "-"' "$@"; cat; } | gnuplot -persist; }

# highlight occurences of expression
hili() { e="$1"; shift; grep --col=always -Eih "$e|$" "$@"; }
# Ditto, but user pager ('n' to iterate)
scan() { e="$1"; shift; less -i -p "*$e" "$@"; }

# Make these functions, common in other languages, available in the shell
ord() { printf "0x%x\n" "'$1"; }
chr() { printf $(printf '\\%03o\\n' "$1"); }

#######################################
# Developer stuff
#######################################

# Enable gcc colours, available since gcc 4.9.0
export GCC_COLORS=1

# Set the section search order for overlapping names
alias man='man -S 2:3:1:4:5:6:7:8'

# setup default search path for python modules.
# Note we add this to the 'path' in .vimrc so the gf
# command will open any .py or .h files etc. in this dir
export PYTHONPATH=~/pb.o/libs/

# for developing: http://udrepper.livejournal.com/11429.html
export MALLOC_CHECK_=3
# The following can cause performance issues
# so ensure unset before performance testing for example
# export MALLOC_PERTURB_=$(($RANDOM % 255 + 1))

# Let me have core dumps
ulimit -c unlimited

# print the corresponding error message
strerror() { python -c "\
import os,locale as l; l.setlocale(l.LC_ALL, ''); print os.strerror($1)"; }

# show extra info in the prompt in git repos
old_git_prompt=/usr/share/doc/git-*/contrib/completion/git-completion.bash
new_git_prompt=/usr/share/git-core/contrib/completion/git-prompt.sh
git_integration=$new_git_prompt
test -e $git_integration || git_integration=$old_git_prompt
if test -e $git_integration; then
  source $git_integration
  export GIT_PS1_SHOWDIRTYSTATE=1
  PS1='\[\e[1m\]\h:\W$(__git_ps1 " (%s)")\$\[\e[0m\] '
fi
# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/bin:$HOME/gems/bin:$PATH"
CPLUS_INCLUDE_PATH="$HOME/include"
export CPLUS_INCLUDE_PATH
