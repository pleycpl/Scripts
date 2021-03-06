#!/bin/bash

# Profile Page: https://github.com/pleycpl
# Organization Page: https://github.com/ProjemVar

# ------------------------------------------------- #
# We are downloading source code in link.           #
# And created allAtags.txt.                         #
# ------------------------------------------------- #
downloadLinks() {
    echo -e "[+] Starting downloadLinks function"
    github="https://github.com"
    username=$1
    pageSize=$2
    touch allAtags.txt
    for page in $(seq ${pageSize})
    do
        echo -e "[+] Page ${page} crawling."
        query="?page=${page}&tab=repositories"
        githubReposLink="${github}/${username}${query}"
        #echo $githubReposLink
        curl $githubReposLink | grep "<a href=\"/${username}/.*" >> allAtags.txt
        echo -e ""
    done
    echo -e "[+] All tags"
    cat allAtags.txt
}

# ------------------------------------------------- #
# And then we strip pure link with awk.             #
# ------------------------------------------------- #
cleanLinks() {
    echo -e "[+] Starting cleanLinks function"
    awk -F"\"" '{print $2}' allAtags.txt > pureLinks.txt
    echo -e "[+] Pure Links"
    cat pureLinks.txt
}

# ------------------------------------------------- #
# Adding host name and protocol to links!           #
# ------------------------------------------------- #
addedProtocolAndHostname() {
    echo -e "[+] Starting addedProtocolAndHostname function"
    replaceString=".*"
    replaceWith="${github}&"
    sed s~$replaceString~$replaceWith~ < pureLinks.txt > pure.txt
    echo -e "[+] Links with Protocol and Hostname"
    cat pure.txt
}

# ------------------------------------------------- #
# Finally we download all repos with git clone      #
# --------------------------------------------------#
downloadRepos() {
    echo -e "[+] Downloading repos...\n"
    for f in `cat pure.txt`
    do
        git clone $f
    done
}

# ------------------------------------------------- #
# Removing unnecessary files                        #
# ------------------------------------------------- #
cleanUpTempFiles() {
    rm allAtags.txt pureLinks.txt pure.txt
}

# ------------------------------------------------- #
# Main Section in Script                            #
# ------------------------------------------------- #
Main() {
    read -p "Entry your github profile name: " profileName
    read -p "Entry your github repository page size: " size
    read -p "Entry the program mode[debug|normal]: " mode
    downloadLinks $profileName $size
    cleanLinks
    addedProtocolAndHostname
    downloadRepos
    if [ $mode == "normal" ]; then
        cleanUpTempFiles
    fi
}

Main
