#!/bin/sh
# System stats collector for DynamicGlacier
# Outputs: CPU_PCT\tRAM_USED_PCT\tCPU_TEMP_C\tRAM_USED_FMT\tRAM_TOTAL_FMT

# CPU usage delta (htop/top/btop method)
read -r PREV_TOTAL PREV_IDLE < /tmp/dg_cpu_prev 2>/dev/null || true
read -r CPU < /proc/stat
CPU=($CPU)
TOTAL=$((${CPU[1]}+${CPU[2]}+${CPU[3]}+${CPU[4]}+${CPU[5]}+${CPU[6]}+${CPU[7]}))
IDLE=${CPU[4]}
if [ -n "$PREV_TOTAL" ] && [ "$TOTAL" -gt "$PREV_TOTAL" ] 2>/dev/null; then
  DIFF_TOTAL=$((TOTAL - PREV_TOTAL))
  DIFF_IDLE=$((IDLE - PREV_IDLE))
  CPU_PCT=$(( (100 * (DIFF_TOTAL - DIFF_IDLE)) / DIFF_TOTAL ))
else
  CPU_PCT=0
fi
echo "$TOTAL $IDLE" > /tmp/dg_cpu_prev

# RAM from /proc/meminfo (available memory method)
eval $(grep -E '^(MemTotal|MemAvailable):' /proc/meminfo | tr -d ' kB' | sed 's/:/=/')
RAM_TOTAL_KB=$MemTotal
RAM_AVAIL_KB=$MemAvailable
RAM_USED_PCT=0
if [ "$RAM_TOTAL_KB" -gt 0 ] 2>/dev/null; then
  RAM_USED_PCT=$(( (100 * (RAM_TOTAL_KB - RAM_AVAIL_KB)) / RAM_TOTAL_KB ))
fi
RAM_USED_DEC=$(( (RAM_TOTAL_KB - RAM_AVAIL_KB) * 10 / 1048576 ))
RAM_USED_INT=$(( RAM_USED_DEC / 10 ))
RAM_USED_FRA=$(( RAM_USED_DEC % 10 ))
RAM_TOTAL_DEC=$(( RAM_TOTAL_KB * 10 / 1048576 ))
RAM_TOTAL_INT=$(( RAM_TOTAL_DEC / 10 ))
RAM_TOTAL_FRA=$(( RAM_TOTAL_DEC % 10 ))
RAM_USED_FMT="${RAM_USED_INT}.${RAM_USED_FRA}"
RAM_TOTAL_FMT="${RAM_TOTAL_INT}.${RAM_TOTAL_FRA}"

# CPU temp - prioritize x86_pkg_temp thermal zone (matches btop), then coretemp Package id 0
CPU_TEMP_C=0

# First try x86_pkg_temp thermal zone (Intel CPU package temp - matches btop)
for t in /sys/class/thermal/thermal_zone*/temp; do
    zone_type=$(cat "${t%/temp}/type" 2>/dev/null || echo "")
    if [ "$zone_type" = "x86_pkg_temp" ]; then
        val=$(cat "$t" 2>/dev/null || continue)
        if [ "$val" -ge 20000 ] && [ "$val" -le 150000 ]; then
            CPU_TEMP_C=$((val / 1000))
            break
        fi
    fi
done

# Fallback to coretemp hwmon Package id 0
if [ "$CPU_TEMP_C" = "0" ]; then
    for h in /sys/class/hwmon/hwmon*/name; do
        if [ "$(cat "$h" 2>/dev/null)" = "coretemp" ]; then
            hwmon_dir="${h%/name}"
            i=1
            for label in "$hwmon_dir"/temp*_label; do
                if [ "$(cat "$label" 2>/dev/null)" = "Package id 0" ]; then
                    pkg_temp=$(cat "$hwmon_dir/temp${i}_input" 2>/dev/null || echo 0)
                    if [ "$pkg_temp" -gt 0 ]; then
                        CPU_TEMP_C=$((pkg_temp / 1000))
                    fi
                    break
                fi
                i=$((i + 1))
            done
            break
        fi
    done
fi

# Final fallback to other thermal zones
if [ "$CPU_TEMP_C" = "0" ]; then
    for t in /sys/class/thermal/thermal_zone*/temp; do
        val=$(cat "$t" 2>/dev/null || continue)
        if [ "$val" -ge 20000 ] && [ "$val" -le 150000 ]; then
            CPU_TEMP_C=$((val / 1000))
            break
        fi
    done
fi

printf '%s\t%s\t%s\t%s\t%s\n' "$CPU_PCT" "$RAM_USED_PCT" "$CPU_TEMP_C" "$RAM_USED_FMT" "$RAM_TOTAL_FMT"