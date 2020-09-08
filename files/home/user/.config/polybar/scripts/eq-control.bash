#!/usr/bin/env bash
# This script assumes that PulseEffects is on the 'Default' preset when
# launched.

TMP_FILE="/tmp/pulseeffects_preset.tmp"

# The default preset name (not the alias).
DEFAULT="Default"
# Custom aliases can be given to the preset names.
declare -A ALIAS
ALIAS["Default"]="Disabled"

function usage() {
    echo "usage: $0 [show|next]" 2>&1
}

function get_current() {
    if [ -f "$TMP_FILE" ]; then
        current=$(cat "$TMP_FILE")
    else
        current="$DEFAULT"
        echo "$DEFAULT" > "$TMP_FILE"
    fi
}

# Prints the current preset, trying to use an alias.
function show() {
    if ! pgrep -x pulseeffects &>/dev/null; then
        echo ""
        exit
    fi

    get_current
    if [ -n "${ALIAS[$current]}" ]; then
        echo "${ALIAS[$current]}"
    else
        echo "$current"
    fi
}

# Switches to the next preset available.
function next() {
    # Obtaining the presets available and printing them twice so that the
    # next one of the current present will always work.
    presets=$(pulseeffects --presets 2>&1 | grep 'Output Presets:' | cut -d' ' -f3 | tr ',' '\n' | sed '/^$/d' | sort)
    get_current
    next=$(echo -e "$presets\n$presets" | awk -v "cur=$current" '$0 ~ cur { getline; print $0; exit }')

    # The new preset is loaded and saved for the next run.
    pulseeffects --load-preset "$next" &>/dev/null
    echo "$next" > "$TMP_FILE"
}

if [ $# -ne 1 ];then
    usage
    exit 1
fi

case "$1" in
    show)
        show
        ;;
    next)
        next
        ;;
    *)
        usage
        ;;
esac
