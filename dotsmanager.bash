#!/usr/bin/env bash
# Ridiculously over-engineered script to manage my dotfiles on Arch Linux
# between multiple computers, for the sake of learning scripting and for fun.
#
# This script will also save information about your installation: installed
# programs, system info, a file tree... These can be configured in the
# `dotsmanager` directory.
#
# Any script in `dotsmanager/scripts` will be executed and redirected into
# the `localinfo` directory. This is useful to for example save your music
# tracks (see `dotsmanager/scripts/spotify.py`).
#
# Requires `rsync`, and if possible `neofetch`.

set -e

# Dotfiles locations, its contents may contain un-expanded tildes ('~'):
# Each included file, line by line.
DOTFILES="dotsmanager/dotfiles.txt"
# Files to be ignored when copying the dotfiles.
DOTS_BLACKLIST="dotsmanager/dotfiles_blacklist.txt"
# File tracking:
# A file per line, with its depth separated by a colon.
DIRECTORIES="dotsmanager/dirs_list.txt"
# Patterns to ignore.
DIRS_BLACKLIST="dotsmanager/dirs_blacklist.txt"

# Localinfo files
FILE_SPECS="localinfo/specs.txt"
FILE_DIRECTORIES="localinfo/directories.txt"
FILE_INSTALLED="localinfo/installed.txt"
FILE_MUSIC="localinfo/music.txt"

# When importing dotfiles into the system, a backup will be made in case
# anything went wrong.
DIR_BACKUPS=".backups"


# Obtains the corresponding path in this repository for a given file.
function get_repo_file() {
    repo_file="files/$(echo "${1//\/home\/$USER/\/home\/user}" | cut -c2-)"
}


# Synchronizes the first directory's contents into the second path. The
# directory for the second path will be created if it doesn't exist.
function synchronize() {
    orig=$1
    dest=$2

    if [ -d "$orig" ] && ( [ -d "$dest" ] || ! [ -e "$dest" ]; ); then
        # Origin node is a directory, so it'll be copied as such.
        mkdir -p "$dest"
        rsync -a "$orig/" "$dest"
    elif [ -f "$orig" ] && ( [ -f "$dest" ] || ! [ -e "$dest" ]; ); then
        mkdir -p "$(dirname "$dest")"
        rsync -a "$orig" "$dest"
    else
        ls -l "$orig" "$dest"
        echo "Cannot sync \"$orig\" and \"$dest\": their types are different."
        exit 1
    fi

    echo ">> \"$orig\" ---> \"$dest\""
}


# Function that prints a directory tree for $1 with a max depth of $2.
function tree() {
    function show_tree() {
        local dir="$1"
        local depth=$2
        if [ "$depth" -le 0 ]; then
            return
        fi

        depth=$((depth - 1))
        for file in "$dir"/*; do
            # Checking if the node exists
            if [ ! -e "$file" ]; then continue; fi

            # Checking that it's not in the blacklist
            if grep -q "$(basename "$file")" "$DIRS_BLACKLIST"; then
                continue
            fi

            # Formatting the directory
            local name
            name=$(echo "$file" | sed -E -e "s:$main_dir/?::g; \
                       s/[^-][^\/]*\//$spaces/g")

            echo "${spaces}${name}"
            show_tree "$file" "$depth"
        done
    }

    spaces=$(printf "%-4s" " ")
    main_dir=$1
    depth=$2

    if [ -d "$main_dir" ]; then
        echo "Tree of \"$main_dir\" with depth $depth:"
        show_tree "$main_dir" "$depth"
    fi
}


function get_packages() {
    # Ignores the packages from `base` and `base-devel`. Part is taken from
    # the Arch Linux Wiki:
    # https://wiki.archlinux.org/index.php/Pacman/Tips_and_tricks#Getting_the_dependencies_list_of_several_packages
    all_packages=$(pacman -Qq | sort)
    base_packages=$(cat <(pacman -Qqg base-devel) <(LC_ALL=C pacman -Si base \
        | awk -F'[:<=>]' '/^Depends/ {print $2}' | xargs -n1) | sort | uniq)
    native_packages=$(comm -23 <(pacman -Qqen | sort) <(echo "$base_packages"))
    external_packages=$(pacman -Qqem | sort)
    installed_packages=$(cat <(echo "$native_packages") <(echo "$external_packages") | sort)
}


function save_sysinfo() {
    echo "Saving the system information"
    get_packages

    echo ">> Saving system information"
    local num_native num_external num_total
    num_native=$(echo "$native_packages" | wc -l)
    num_external=$(echo "$external_packages" | wc -l)
    num_total=$((num_native + num_external))
    (
        echo "Last update made on $(date).
$num_total explicitly installed programs:
    * $num_native native
    * $num_external external (AUR, PKGBUILDs)
"
        neofetch --stdout 2>/dev/null || uname -a
    ) > "$FILE_SPECS"

    echo ">> Saving installed packages"
    (
        echo "$native_packages"
        echo "$external_packages" | sed 's/.*/& (AUR)/'
    ) | sort > "$FILE_INSTALLED"

    echo ">> Saving directory trees"
    while IFS=':' read -r folder depth <&3; do
        folder=${folder/#\~/$HOME}
        tree "$folder" "$depth"
        echo ""
    done 3< "$DIRECTORIES" > "$FILE_DIRECTORIES"
}


function run_scripts() {
    echo "Running custom scripts"
    for file in dotsmanager/scripts/*; do
        if [ -x "$file" ]; then
            into="localinfo/scripts/$(basename "$file").output"
            echo ">> Running $file with output redirected into $into"
            if ! "$file" > "$into"; then
                echo ">> Failed to run the script, skipping"
            fi
        fi
    done
}


function export_files() {
    echo "Exporting files"

    while read -r local_file <&3; do
        local_file=${local_file/#\~/$HOME}
        if ! [ -e "$local_file" ]; then
            echo "Skipping \"$local_file\" (doesn't exist)"
            continue
        fi

        # Getting where it should be saved.
        get_repo_file "$local_file"

        # Cleaning up previous files and copying it again into the repo.
        rm -rf "$repo_file"
        synchronize "$local_file" "$repo_file"
    done 3< "$DOTFILES"

    # Removing those blacklisted
    while read -r local_file <&3; do
        local_file=${local_file/#\~/$HOME}
        get_repo_file "$local_file"
        rm -rf "$repo_file"
    done 3< "$DOTS_BLACKLIST"
}


function import_files() {
    echo "Importing files"

    # Diff between two subdirectories skipping files that aren't in both of
    # them.
    function show_diff() {
        (echo "DIFF BETWEEN $2 (repo) AND $1 (local)" && diff --color=always --recursive "$2" "$1") | less -R
    }

    # Same function as above but returns a boolean indicating if both
    # directories are the same or not.
    function dirs_differ() {
        [ "$(diff --brief --recursive "$1" "$2" | sed -e '/^Only in .\+: .*/d' | wc -l)" -ne 0 ]
    }

    # Sync the repo files into the computer. The removed files will be moved
    # to a directory in case the user made a mistake.
    function sync_to_local() {
        local repo_file=$1
        local local_file=$2

        while true; do
            echo -n "Copy \"$repo_file\" into \"$local_file\"? [y/n]: "
            read -r
            if [ "$REPLY" = "y" ]; then
                # Saving a backup of the local file, and overwriting it.
                if [ -e "$local_file" ]; then
                    synchronize "$local_file" "$DIR_BACKUPS/$repo_file"
                fi
                synchronize "$repo_file" "$local_file"
                break
            elif [ "$REPLY" = "n" ]; then
                echo "Skipping \"$local_file\""
                break
            fi
        done
    }

    while read -r local_file <&3; do
        local_file=${local_file/#\~/$HOME}
        get_repo_file "$local_file"

        # File from repo isn't available, so nothing is done
        if ! [ -e "$repo_file" ]; then
            echo "Skipping \"$local_file\" (doesn't exist in repo)"
            continue
        fi

        if ! [ -e "$local_file" ]; then
            # File in the device doesn't exist, so it's directly copied over
            sync_to_local "$repo_file" "$local_file"
        else
            if ! dirs_differ "$local_file" "$repo_file"; then
                # If they are the same, nothing is done.
                echo "Already synced \"$local_file\""
                continue
            fi

            # If the local file is different from the repo's, it's synced.
            show_diff "$repo_file" "$local_file"
            sync_to_local "$repo_file" "$local_file"
        fi
    done 3< "$DOTFILES"
}


function install_packages() {
    # List with packages not already installed
    echo "Installing packages"
    get_packages

    # Iterates the packages that aren't already installed on this device,
    # prompting the user. At the end, all the installations are done at
    # once.
    local chosen_packages
    while read -r package <&3; do
        while true; do
            echo -n "Install ${package}? [y/n]: "
            read -r
            if [ "$REPLY" = "y" ]; then
                chosen_packages="$chosen_packages $package"
                break
            elif [ "$REPLY" = "n" ]; then
                break
            fi
        done
    done 3< <(comm -23 \
        <(sort "$FILE_INSTALLED" | sed '/ (AUR)$/d') \
        <(echo "$installed_packages"))

    if [ -z "$chosen_packages" ]; then
        echo "No packages to install"
        return
    fi

    echo "$chosen_packages" | xargs --open-tty yay -S
}


function usage() { 
    echo "$0 usage:"
    echo "help      show this message"
    echo "export    export both the config files and the system information into this repo"
    echo "import    import the repo's config files into this computer one by one"
    echo "install   install the packages in $FILE_INSTALLED into this computer"
}


if [ $# -ne 1 ];then
    usage
    exit 1
fi

case "$1" in
    export)
    save_sysinfo
    run_scripts
    export_files
    ;;
    import)
    import_files
    ;;
    install)
    install_packages
    ;;
    *)
    usage
    ;;
esac
