#!/bin/bash
set -eu
function status {
    msg=""
    date_=$(date '+%Y-%m-%d %H:%M %a')

    [[ "$(amixer get Master || true)" =~ [0-9]{1,3}% ]]
    vol="${BASH_REMATCH[@]}"
    vol=${vol%\%}

    battery=$(acpi | egrep -o '[0-9]+\%')
    battery=${battery%\%}
    [[ $battery -lt 30 ]] && msg+="| BATTERY LOW"
    if ! acpi | grep Charging >/dev/null; then
        [[ $battery -lt 20 ]] && ding
    fi

    new_msgs=$(ls ~/mail/new | wc -l)
    [[ "$new_msgs" -gt 0 ]] && msg+="| $new_msgs new msgs"

    loadavg=$(awk '{if ($1 > 2) {print $1}}' /proc/loadavg)
    [[ -n "$loadavg" ]] && msg+="| loadavg=$loadavg"

    swap_pct=$(free | awk '
        /^Swap:/ {
            total = $2
            used = $3
            pct = used / total * 100
            if (pct > 5){
                print pct
            }
        }'
    )
    [[ -n "$swap_pct" ]] && msg+="| swap_pct=$swap_pct"

    xsetroot -name "$date_ | v$vol | b$battery $msg"
}

while getopts "c" opt; do
    case "$opt" in
        c) cont=yes;;
        *) exit 1;;
    esac
done

status

[[ -z "${cont:-}" ]] && exit 0

while true; do
    sleep 10
    status
done 2>>~/.status.sh.log &
