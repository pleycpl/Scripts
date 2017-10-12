#!/usr/bin/env bash
### Global Variables
declare -A ALL_SITE_PACKAGES_PATHS=(
    ["py2"]=""
    ["py3"]=""
)
declare -a InitialFiles=("")

function init() {
    # Set up global arrays, finding all py3 or py2 site-packages path 
    echo "[+] init function"
    ALL_SITE_PACKAGES_PATHS["py2"]=$(find $HOME -name site-packages -type d | grep 'python2' )
    ALL_SITE_PACKAGES_PATHS["py3"]=$(find $HOME -name site-packages -type d | grep 'python3' )
}
function print_site_packages_paths {
    # printing "site_packages" paths in global ALL_SITE_PACKAGES_PATHS for python version
    local python_version=$1
    echo "[+] print_site_packages_paths() python_version: $python_version"
    for Site_Packages_Path in ${ALL_SITE_PACKAGES_PATHS[$python_version]}; do
        echo ${Site_Packages_Path}
    done
}
function usage {
    # bash offlinePip3forPython3.sh py3 ~/venv install telepot
    echo "./main.sh <py3|py2> <my_venv_path> <install|remove> <package_name>"
}

function read_init_files {
    # reading virtualenv's init files
    local path=/tmp/venv/lib/python3*/site-packages
    echo "[+] read_init_files path: $path"
    virtualenv /tmp/venv
    for initial_file in $(ls $path); do
        InitialFiles+=($initial_file)
    done
}

function read_downloaded_packages_in_site_packages {
    local path=$1
    local outputfile=$2
    echo "[+] read_downloaded_packages_in_site_packages() path: $path outputfile: $outputfile"
    for file in $(ls $path); do
        [[ "${InitialFiles[@]}" == *"$file"* ]] && continue # if it is init file, it doesn't adding "packagelist_py2.txt" or "packagelist_py3.txt" file
        echo $file ${path}/${file} >> $outputfile
    done
}
function read_all_package_path {
    local python_version=$1
    echo "[+] read_all_package_path, python_version: $python_version"
    for Site_Packages_Path in ${ALL_SITE_PACKAGES_PATHS[$python_version]}; do
        # path of all package in "site_packages" is adding to "packagelist_py2.txt" or "packagelist_py3.txt" file.
        read_downloaded_packages_in_site_packages $Site_Packages_Path packagelist_${python_version}.txt
    done
}
function install {
    # installing package
    local package_name=$1
    local python_version=$2
    echo "[+] install() package_name: $package_name python_version: $python_version"
    for line in $( awk '{ print NR, $1}' packagelist_${python_version}.txt |\
                    grep -i $package_name |\
                    awk '{ print $1 }'); do
        sed "${line}q;d" packagelist_${python_version}.txt
        #awk -v n=$line 'NR == n' packagelist_${python_version}.txt
    done
}
function main {
    local python_status=$1  # Like py3 or py2
    local my_venv_path=$2   # Currently, Please insert full path. Like /home/<user_name>/....
    local status=$3         # "install" or "remove" 
    local package_name=$4   # package_name.
    init
    print_site_packages_paths $python_status
    read_init_files
    echo ${InitialFiles[@]}
    rm packagelist_py2.txt packagelist_py3.txt 2> /dev/null
    read_all_package_path $python_status
    install $package_name $python_status
}

main "$@"

# ...../site-packages/<package_name>
# ...../site-packages/<package_name>-<version>.dist-info
# flask             Flask-0.12.2.dist-info
# itsdangerous.py   itsdangerous-0.24.dist-info
# flask_mysqldb     Flask_MySQLdb-0.2.0.dist-info
# markupsafe        MarkupSafe-1.0.dist-info
# jinja2            Jinja2-2.9.6.dist-info
# click             click-6.7.dist-info
