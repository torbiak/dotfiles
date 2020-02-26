#!/bin/bash
set -eu
function status {
    local msg=""
    local date=$(date '+%Y-%m-%d %H:%M %a')

    mixer="$(amixer get Master)"
    [[ "$mixer" =~ [0-9]{1,3}% ]]
    vol="${BASH_REMATCH%\%}"
    [[ "$mixer" = *"[off]"* ]] && vol+=m

    acpi=$(acpi -b)
    [[ "$acpi" =~ [0-9]{2,3}% ]]
    pct_charge=${BASH_REMATCH%\%}
    ((pct_charge < 30)) && {
        [[ "$acpi" = *Charging* ]] && msg+=" | BATTERY LOW" || msg+=" | BATTERY DISCHARGING"
    }
    [[ $pct_charge -lt 20 && "$acpi" != *Charging* ]] && ding

    new_msgs=$(ls ~/mail/new | wc -l)
    [[ "$new_msgs" -gt 0 ]] && msg+=" | $new_msgs new msgs"

    loadavg=$(awk '{if ($1 > 2) {print $1}}' /proc/loadavg)
    [[ -n "$loadavg" ]] && msg+=" | loadavg=$loadavg"

    swap_pct=$(free | awk '
        /^Swap:/ {
            total = $2
            used = $3
            pct = used / total * 100
            if (pct > 5){
                printf "%.0f", pct
            }
        }'
    )
    [[ -n "$swap_pct" ]] && msg+=" | swap_pct=$swap_pct"

    xsetroot -name "$date | v$vol | b$pct_charge ${msg# }"
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
