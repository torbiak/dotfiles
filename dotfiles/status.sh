#!/bin/bash
set -eu

logfile=~/.status.sh.log
status() {
    local msg=""
    local date
    date=$(date '+%Y-%m-%d %H:%M %a')

    mixer="$(amixer -D pulse get Master)"
    [[ "$mixer" =~ [0-9]{1,3}% ]]
    vol="${BASH_REMATCH%\%}"
    [[ "$mixer" = *"[off]"* ]] && vol+=m

    acpi=$(acpi -b | grep -v 'rate information unavailable')
    [[ "$acpi" =~ [0-9]{1,3}% ]]
    pct_charge=${BASH_REMATCH%\%}
    ((pct_charge < 30)) && {
        [[ "$acpi" = *Charging* ]] && msg+=" | BATTERY LOW" || msg+=" | BATTERY DISCHARGING"
    }
    [[ $pct_charge -lt 20 && "$acpi" != *Charging* ]] && ding

    new_msgs=$(find ~/mail/new -type f | wc -l)
    [[ "$new_msgs" -gt 0 ]] && msg+=" | $new_msgs new msgs"

    loadavg=$(awk '{if ($1 > 2) {print $1}}' /proc/loadavg)
    [[ -n "$loadavg" ]] && msg+=" | loadavg=$loadavg"

    mem_avail_pct=$(free | awk '
        /^Mem:/ {
            total = $2
            avail = $7
            pct = avail / total * 100
            if (pct < 30){
                printf "%.0f", pct
            }
        }'
    )
    [[ -n "$mem_avail_pct" ]] && msg+=" | mem_avail_pct=$mem_avail_pct"

    if [[ -e ~/.last_workout ]] && (($(date +%s) - "$(stat --printf=%Y ~/.last_workout)" > 90*60)); then
        msg+=" | WORKOUT"
    fi

    if [[ -e ~/status_msg ]]; then
        for f in ~/status_msg/*; do
            [[ -e "$f" ]] || continue
            msg+=" | ${f##*/}"
        done
    fi

    xsetroot -name "$date | v$vol | b$pct_charge ${msg# }"
}

while getopts "c" opt; do
    case "$opt" in
        c) cont=yes;;
        *) exit 1;;
    esac
done

if [[ -z "${cont:-}" ]]; then
    status
    exit 0
fi

while true; do
    status
    sleep 10
done &>>"$logfile"
