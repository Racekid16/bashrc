# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# everything from this point on was added by me

# variables that the user can manipulate via the provided interface
min_spaces=30
git_info_enabled=1
auto_git_fetch=1

# Define colors
pink='\[\033[95m\]'
orange='\[\033[38;5;208m\]'
yellow='\[\033[1;33m\]'
green='\[\033[0;32m\]'
red='\[\033[0;31m\]'
reset='\[\033[0m\]'

# Store the original PS1- this is templated, not a static literal
original_PS1="${PS1}"

# Store the previous git branch you were on
previous_branch=""
previous_commit_hash=""

# These are functions that are meant to be called from the terminal

# Function to set the min_spaces variable directly from the terminal
# ex: $ set_min_spaces 20
# Set this to a very negative value if you don't want cwd truncation
set_min_spaces() {
    if [[ "$1" =~ ^-?[0-9]+$ ]]; then
        sed -i "s/^min_spaces=.*$/min_spaces=$1/" ~/.bashrc
        export min_spaces=$1
        echo "min_spaces set to $1"
    else
        echo "Invalid input. Please provide an integer."
    fi
}

# Function to toggle git info printing
# usage: $ toggle_git_info
toggle_git_info() {
    if [ $git_info_enabled -eq 0 ]; then
        git_info_enabled=1
        echo "git_info enabled"
    else
        git_info_enabled=0
        echo "git_info disabled"
    fi
    sed -i "s/^git_info_enabled=.*$/git_info_enabled=${git_info_enabled}/" ~/.bashrc
    export git_info_enabled
}

# Function to toggle automatically running $ git fetch whenever entering a new branch
# usage: $ toggle_auto_git_fetch
toggle_auto_git_fetch() {
    if [ $auto_git_fetch -eq 0 ]; then
        auto_git_fetch=1
        echo "auto_git_fetch enabled"
    else
        auto_git_fetch=0
        echo "auto_git_fetch disabled"
    fi
    sed -i "s/^auto_git_fetch=.*$/auto_git_fetch=${auto_git_fetch}/" ~/.bashrc
    export auto_git_fetch
}

# these are functions that are not meant to be called from the terminal

# Function to handle SIGINT signal (Ctrl+C)
sigint_handler() {
    local cols=$(tput cols)  # Get the number of columns in the terminal
    local msg="SIGINT"

    # Calculate the number of spaces needed to move to the rightmost side of the terminal
    local spaces=$((cols - ${#msg}))

    # Move cursor to the rightmost side of the terminal
    echo -en "\033[${spaces}C"
    echo -n "$msg"
}

# Function to handle SIGTSTP signal (Ctrl+Z)
sigtstp_handler() {
    local cols=$(tput cols) # Get the number of columns in the terminal
    local msg="SIGTSTP"

    # Calculate the number of spaces needed to move to the rightmost side of the terminal
    local spaces=$((cols - ${#msg}))

    # Move cursor to the rightmost side of the terminal
    echo -en "\033[${spaces}C"
    printf "%s\n" "$msg"
}

# Function to handle ERR signal (commands with an error exit status)
err_handler() {
    local exit_status=$?
    local cols=$(tput cols)  # Get the number of columns in the terminal
    local msg_1="✗"
    local msg_2=" ${exit_status}"

    # Calculate the number of spaces needed to move to the rightmost side of the terminal
    local spaces=$((cols - ${#msg_1} -${#msg_2}))

    # Move the cursor up one line
    printf "\033[1A"
    # Move cursor to the rightmost side of the terminal
    echo -en "\033[${spaces}C"
    echo -e "\033[31m${msg_1}\033[0m${msg_2}"
}

# Get the current working directory, but with the home diretory replaced with ~
get_cleaned_cwd() {
    local cwd=$(pwd)
    local home_dir=$(eval echo "~")
    cwd=${cwd//$home_dir/'~'}
    echo "$cwd"
}

# Function to truncate the cwd part of PS1 if it's longer than min_spaces characters
truncate_cwd() {
    local cwd="$1"
    local cwd_new_length="$2"
    local cwd_length=${#cwd}

    local y=$((cwd_new_length - 3))
    local x=$(( y / 2 ))

    local prefix_upper=$x
    local suffix_lower
    if [ $((cwd_new_length % 2)) -eq 0 ]; then
        suffix_lower=$(( cwd_length - x - 1 ))
    else
        suffix_lower=$(( cwd_length - x ))
    fi

    local prefix="${cwd:0:prefix_upper}"
    local suffix="${cwd:suffix_lower}"
    local result="${prefix}...${suffix}"
    echo "$result"
}

# Return the PS1 with the truncated cwd
insert_truncated_cwd() {
    local output_PS1="$1"
    local truncated_cwd="$2"
    echo "${output_PS1//\\w/$truncated_cwd}"
}

# Determine whether this directory is a git repository
is_git_repository() {
    git rev-parse --is-inside-work-tree &>/dev/null;
}

# Function to get the current git branch
get_current_git_branch() {
    echo "$(git branch --show-current 2>/dev/null)"
}

# gets the hash of the commit that the current branch is pointing to
get_current_commit_hash() {
    git rev-parse HEAD
}

# return true if the remote branch associated with this local branch has changed and false otherwise
detect_remote_branch_changes() {
    # Check if there is a remote repository associated with the local repository
    # and that there is at least one commit in this local branch
    if ! git remote -v | grep -q '^origin\s'; then
        return
    fi

    # Check if the current branch has an upstream branch set
    if ! git rev-parse --abbrev-ref --symbolic-full-name @{upstream} >/dev/null 2>&1; then
        return
    fi

    local current_branch=$(get_current_git_branch)
    local remote_branch=$(git for-each-ref --format='%(upstream:short)' refs/heads/"$current_branch")

    local prev_remote_commit_hash=$(git rev-parse "$remote_branch")
    git fetch
    local remote_commit_hash=$(git rev-parse "$remote_branch")

    if [ "$remote_commit_hash" != "$prev_remote_commit_hash" ]; then
        echo
        echo "Changes detected in the remote branch '$remote_branch'."
        echo "To retrieve these changes, run $ git pull"
    fi
}

# Function to check if the current branch is different than the previous branch
branch_has_changed() {
    local current_branch=$(get_current_git_branch)
    local current_commit_hash=$(get_current_commit_hash)

    if [ "$current_branch" != "$previous_branch" ] || [ "$current_commit_hash" != "$previous_commit_hash" ]; then
        previous_branch=$current_branch
        previous_commit_hash=$current_commit_hash
        return 0
    else
        previous_branch=$current_branch
        previous_commit_hash=$current_commit_hash
        return 1
    fi
}

# Function to count the number of commits away from the initial commit
commit_count() {
    git rev-list --count HEAD 2>/dev/null || echo 0
}

merge_conflict_count() {
    git status --porcelain | grep '^UU' | awk '{print $2}' | wc -l
}

# Function to count the number of staged files
staged_files_count() {
    git diff --staged --name-only | wc -l
}

# Function to count the number of modified but unstaged files
modified_files_count() {
    git diff --name-only | wc -l
}

# Output the truncated PS1 with git information
update_PS1() {
    local output_PS1="${original_PS1}"
    local PS1_length=0

    # because I changed the PS1, virtual environment activate scripts would no longer add the (env)
    # so this adds it manually
    if [ -n "$VIRTUAL_ENV" ]; then
        venv_name=$(basename "$VIRTUAL_ENV")
        venv_prompt="(${pink}${venv_name}${reset}) "
        output_PS1="${venv_prompt}${output_PS1}"
        PS1_length=$((PS1_length + 3 + ${#venv_name}))
    fi

    # Indicate whether you're in a ssh session
    if [ -n "$SSH_CONNECTION" ]; then
        ssh_prompt="(${orange}SSH${reset}) "
        output_PS1="${ssh_prompt}${output_PS1}"
        PS1_length=$((PS1_length + 6))
    fi

    user_length=$(printf "%s" "$USER" | wc -c)
    host_length=$(hostname | tr -d '\n' | wc -c)
    # Accounts for the @ and : too
    PS1_length=$((PS1_length + user_length + host_length + 2))

    local cwd=$(get_cleaned_cwd)
    local cwd_length=${#cwd}
    PS1_length=$((PS1_length + cwd_length))

    if is_git_repository; then
        local num_commits=$(commit_count)
        if [ $git_info_enabled -eq 1 ]; then
            # gets the substring that appears before the last \$ in PS1
            output_PS1=$(echo "$output_PS1" | sed -E 's/^(.*?)\\\$ .*/\1/') 

            local branch=$(get_current_git_branch)
            local conflict_count=$(merge_conflict_count)
            local staged_count=$(staged_files_count)
            local modified_count=$(modified_files_count)

            # Accounts for the extra space and opening and closing parenthesis
            PS1_length=$((PS1_length + 3))

            local branch_info="${yellow}${branch}${reset}"
            PS1_length=$((PS1_length + ${#branch}))

            local commit_info=""
            if [ "$num_commits" -gt 0 ]; then
                commit_info=" ↑${yellow}${num_commits}${reset}"
                # Accounts for ↑ and the space that directly precedes it too
                PS1_length=$((PS1_length + ${#num_commits} + 2))
            fi

            local git_info=""
            if [ "$conflict_count" -gt 0 ]; then
                git_info=" ${red}conflicts${reset}:${red}${conflict_count}${reset}"
            elif [ "$staged_count" -gt 0 ] || [ "$modified_count" -gt 0 ]; then
                git_info=" ${green}${staged_count}${reset}:${red}${modified_count}${reset}"
                # Accounts for the : and the space that directly precedes the staged count too
                PS1_length=$((PS1_length + ${#staged_count} + ${#modified_count} + 2))
            fi

            # the suffix is directly set to this instead of using the original suffix, 
            # because using the original suffix causes issues with text in the terminal not line wrapping
            local suffix="\\$ "

            output_PS1="${output_PS1} (${branch_info}${commit_info}${git_info})${suffix}"
        fi
        
        if [ "$auto_git_fetch" -eq 1 ] && [ "$num_commits" -gt 0 ] && branch_has_changed; then
            detect_remote_branch_changes
        fi
    else
        previous_branch=""
        previous_commit_hash=""
    fi

    # Accounting for the $ and the space after it
    PS1_length=$((PS1_length + 2))

    local terminal_width=$(tput cols)  # Get the number of columns in the terminal
    local num_spaces=$((terminal_width - PS1_length))
    if [ "$num_spaces" -lt "$min_spaces" ]; then
        local space_difference=$((min_spaces - num_spaces))
        local cwd_new_length=$((cwd_length - space_difference ))
        local truncated_cwd=$(truncate_cwd "$cwd" "$cwd_new_length")
        output_PS1=$(insert_truncated_cwd "$output_PS1" "$truncated_cwd")
    fi

    PS1="${output_PS1}"
}

# Set up signal handlers
trap 'sigint_handler' SIGINT
trap 'sigtstp_handler' SIGTSTP
trap 'err_handler' ERR

# Execute update_PS1 function before displaying each prompt
PROMPT_COMMAND=update_PS1
. "$HOME/.cargo/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
