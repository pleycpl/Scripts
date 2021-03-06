#!/usr/bin/env bash
declare -A UsersAndEmails=(
    ["pleycpl"]="pleycpl@protonmail.com"
    ["example"]="example@gmail.com"
)

function set_git_username {
    echo "[+] set_git_username function"
    local username=$1
    git config --global user.name $username
}

function set_git_email {
    echo "[+] set_git_email function"
    local email=$1
    git config --global user.email $email
}

function main {
    echo "[+] Main function"
    if [ ! "$#" -gt 0 ]; then
        echo "Please entry some arguman"
        exit 1
    fi
    local username=$1
    local email=${UsersAndEmails[$username]}
    if [[ $email == "" ]]; then
        echo "I'm sorry, there isn't any username"
        exit 1
    fi
    set_git_username $username
    set_git_email $email
}

main $@
### Changing prompt, add .zshrc or .bashrc file
# OLDPS1=$PS1
# PS1=\($(git config --global user.name)\)$PS1

### Next step, ssl keys
