#!/bin/bash


temp=$(expr $(cat /sys/devices/virtual/thermal/thermal_zone0/temp) / 1000)
pwm=$(cat /sys/devices/platform/odroidu2-fan/pwm_duty | sed 's/.* : .* -> //g' | sed -e 's/.(.*).//g')
start_temp=$(cat /sys/devices/platform/odroidu2-fan/start_temp | sed 's/.* : .* -> //g' | sed -e 's/.(.*)//g')	
warn=$(expr $(cat /sys/devices/virtual/thermal/thermal_zone0/trip_point_0_temp) / 1000)	
critical=$(expr $(cat /sys/devices/virtual/thermal/thermal_zone0/trip_point_2_temp) / 1000)

printf "%d\n%s\n%s\n%d\n%d\n" "$temp" "$pwm" "$start_temp" "$warn" "$critical"
