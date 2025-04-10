#!/bin/sh

max=11
for i in `seq 0 $max`
do
	echo 3600000 > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
	echo performance | tee /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
done
