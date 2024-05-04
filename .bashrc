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
. "$HOME/.cargo/env"

# everything from this point on was added by me
# a command to quickly switch to my windows directly
# usage: $ cdw
alias cdw='cd /mnt/c/Users/17508/Documents/VSCode_Projects'

# variables that the user can manipulate via the provided interface
max_length=65
git_info_enabled=1
auto_env_activation=1
session_auto_env_activation=1

# Define colors
pink='\[\033[95m\]'
yellow='\[\033[1;33m\]'
green='\[\033[0;32m\]'
red='\[\033[0;31m\]'
reset='\[\033[0m\]'

# Store the original PS1- this is templated, not a static literal
original_PS1="${PS1}"

# These are functions that are meant to be called from the terminal

# Function to set the max_length variable directly from the terminal
# ex: $ set_max_length 59
set_max_length() {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        if (( $1 >= 3 )) && (( $1 % 2 != 0 )); then
            sed -i "s/^max_length=.*$/max_length=$1/" ~/.bashrc
            export max_length=$1
            echo "max_length set to $1"
        else
            echo "Please provide a positive odd number greater than or equal to 3 for max_length."
        fi
    else
        echo "Invalid input. Please provide a positive integer."
    fi
}

# Function to toggle git info printing
# usage: $ toggle_git_info
toggle_git_info() {
    if [[ $git_info_enabled -eq 0 ]]; then
        git_info_enabled=1
        echo "git_info enabled"
    else
        git_info_enabled=0
        echo "git_info disabled"
    fi
    sed -i "s/^git_info_enabled=.*$/git_info_enabled=$git_info_enabled/" ~/.bashrc
    export git_info_enabled
}


# Function to toggle automatically activating virtual environments
# usage: $ toggle_auto_env_activation
toggle_auto_env_activation() {
    if [[ $auto_env_activation -eq 0 ]]; then
        auto_env_activation=1
        session_auto_env_activation=1
        echo automatic virtual environment activation enabled
    else
        auto_env_activation=0
        echo automatic virtual environment activation disabled
    fi
    sed -i "s/^auto_env_activation=.*$/auto_env_activation=$auto_env_activation/" ~/.bashrc
    export auto_env_activation
}

# these are functions that are not meant to be called from the terminal

# Function to check if the env/ folder exists in the current or parent directories
check_env_folder() {
    local dir="$PWD"
    local env_folders=("env" "venv" "venv3" ".venv")
    while [ "$dir" != "/" ]; do
        for folder in "${env_folders[@]}"; do
            if [ -d "$dir/$folder" ]; then
                return 0  # Virtual environment folder found
            fi
        done
        dir=$(dirname "$dir")  # Move to the parent directory
    done
    return 1  # Virtual environment folder not found
}

# Function that gets the path to the env assuming there is one
find_env_folder() {
    local dir="$PWD"
    local env_folders=("env" "venv" "venv3" ".venv")
    while [ "$dir" != "/" ]; do
        for folder in "${env_folders[@]}"; do
            if [ -d "$dir/$folder" ]; then
                echo "$dir/$folder"  # Echo the path to the virtual environment folder
                return               # Stop the loop once the folder is found
            fi
        done
        dir=$(dirname "$dir")  # Move to the parent directory
    done
}

# Function for when a user manually deactivates the a virtual environment
# (not run when this script runs deactivate)
user_deactivate() {
    session_auto_env_activation=0
    $deactivate_copy
    unalias deactivate
    echo automatic virtual environment activation disabled for this session
    echo to disable the setting, run \$ toggle_auto_env_activation
}

# Function to check if git info printing is enabled
is_git_info_enabled() {
    [[ $git_info_enabled -eq 1 ]]
}

# Function to handle SIGINT signal (Ctrl+C)
sigint_handler() {
    local cols=$(tput cols)  # Get the number of columns in the terminal
    local msg="SIGINT"

    # Calculate the number of spaces needed to move to the rightmost side of the terminal
    local spaces=$((cols - ${#msg} - 1))

    # Move cursor to the rightmost side of the terminal
    echo -en "\033[${spaces}C"
    echo -n "$msg"
}

# Function to handle SIGTSTP signal (Ctrl+Z)
sigtstp_handler() {
    local cols=$(tput cols)  # Get the number of columns in the terminal
    local msg="SIGTSTP"

    # Calculate the number of spaces needed to move to the rightmost side of the terminal
    local spaces=$((cols - ${#msg} - 1))

    # Move cursor to the rightmost side of the terminal
    echo -en "\033[${spaces}C"
    printf "%s\n" "$msg"
}

# Function to handle ERR signal (commands with exit status 1)
err_handler() {
    local cols=$(tput cols)  # Get the number of columns in the terminal
    local msg_1="✗"
    local msg_2=" 1"

    # Calculate the number of spaces needed to move to the rightmost side of the terminal
    local spaces=$((cols - ${#msg_1} -${#msg_2} - 1))

    # Move the cursor up one line
    printf "\033[1A"
    # Move cursor to the rightmost side of the terminal
    echo -en "\033[${spaces}C"
    echo -e "\033[31m${msg_1}\033[0m${msg_2}"
}

# Function to truncate the cwd part of PS1 if it's longer than max_length characters
truncate_cwd() {
    local cwd="$1"
    local cwd_length=${#cwd}
    local middle_index=$(( (cwd_length - 1) / 2 ))
    local num_cut=$(( cwd_length - max_length + 3 ))
    local prefix_upper=$(( middle_index - ((num_cut + 1) / 2) + 1 ))
    local suffix_lower=$(( middle_index + (num_cut / 2) + 1 ))
    local prefix="${cwd:0:prefix_upper}"
    local suffix="${cwd:suffix_lower}"

    local result="${prefix}...${suffix}"
    echo "$result"
}

# return the truncated cwd with the appropriate prefix and suffix
truncate_ps1() {
    local ps1="$1"
    local cwd="$2"
    # trailing spaces are removed from the prefix, since it results in an extra space between 
    # the prefix and cwd
    local prefix=$(echo "$ps1" | sed -E 's/(.*:)(.*\w)(.*\$)/\1/' | sed -e 's/[[:space:]]*$//')
    local suffix="\\$ "
    echo "${prefix}${cwd}${suffix}"
}

# Get the current working directory, but with the home diretory replaced with ~
get_cleaned_cwd() {
    local cwd=$(pwd)
    local home_dir=$(eval echo "~")
    cwd=${cwd//$home_dir/'~'}
    echo "$cwd"
}

# Determine whether this directory is a git repository
is_git_repository() {
    git rev-parse --is-inside-work-tree &>/dev/null;
}

# Function to get the current git branch
parse_git_branch() {
    echo "$(git branch --show-current 2>/dev/null)"
}

# Function to count the number of commits away from the initial commit
commit_count() {
    git rev-list --count HEAD 2>/dev/null || echo 0
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

    local cwd=$(get_cleaned_cwd)
    if [ ${#cwd} -gt "$max_length" ]; then
        local truncated_cwd=$(truncate_cwd "$cwd")
        # finds the original color of the cwd
        local cwd_color=$(echo "$original_PS1" | grep -oP '\\[\\033\[[0-9;]*m\\](?=\\w)')
        local cwd="${cwd_color}${truncated_cwd}${reset}"
        output_PS1=$(truncate_ps1 "$output_PS1" "$cwd")
    fi

    # Automatically activate or deactivate virtual environment
    if check_env_folder; then
        if [ -z "$VIRTUAL_ENV" ] && [ "$auto_env_activation" = 1 ] && [ "$session_auto_env_activation" = 1 ]; then
            # Activate the virtual environment
            env_path=$(find_env_folder)
            source "${env_path}/bin/activate"
            deactivate_copy=$(type deactivate | sed '1d')
            alias deactivate='user_deactivate'
        fi
    else
        if [ -n "$VIRTUAL_ENV" ]; then
            # for some reason, even if deactivate is alias'd, it'll use
            # the virtual environment's deactivate
            deactivate
            if [[ $(type -t deactivate) == "alias" ]]; then
                unalias deactivate
            fi
        fi
    fi

    # because I changed the PS1, virtual environment activate scripts would no longer add the (env)
    # so this adds it manually
    if [ -n "$VIRTUAL_ENV" ]; then
        venv_name=$(basename "$VIRTUAL_ENV")
        venv_prompt="(${pink}${venv_name}${reset}) "
        output_PS1="${venv_prompt}${output_PS1}"
    fi

    if is_git_repository && is_git_info_enabled; then
        # gets the substring that appears before the last \$ in PS1
        output_PS1=$(echo "$output_PS1" | sed -E 's/^(.*?)\\\$ .*/\1/')
        # the suffix is directly set to this instead of using the original suffix, 
        # because using the original suffix causes issues with text in the terminal not line wrapping
        local suffix="\\$ "

        local staged_count=$(staged_files_count)
        local modified_count=$(modified_files_count)
        local branch=$(parse_git_branch)
        local commits=$(commit_count)

        local git_info=""
        if [ "$staged_count" -gt 0 ] || [ "$modified_count" -gt 0 ]; then
            git_info=" ${green}${staged_count}${reset}:${red}${modified_count}${reset}"
        fi

        local commit_info=""
        if [ "$commits" -gt 0 ]; then
            commit_info=" ↑${yellow}${commits}${reset}"
        fi

        local branch_info="${yellow}${branch}${reset}"

        output_PS1="${output_PS1} (${branch_info}${commit_info}${git_info})${suffix}"
    fi

    PS1="${output_PS1}"
}

# Set up signal handlers
trap 'sigint_handler' SIGINT
trap 'sigtstp_handler' SIGTSTP
trap 'err_handler' ERR

# Execute update_PS1 function before displaying each prompt
PROMPT_COMMAND=update_PS1