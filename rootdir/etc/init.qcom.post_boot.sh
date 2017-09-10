#!/system/bin/sh
# Copyright (c) 2012-2013, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

target=`getprop ro.board.platform`
case "$target" in
    "msm8952")

        #Enable adaptive LMK and set vmpressure_file_min
        ProductName=`getprop ro.product.name`
        MemTotalStr=`cat /proc/meminfo | grep MemTotal`
        MemTotal=${MemTotalStr:16:8}
        if [ $MemTotal -le 2097152 ]; then
            #Enable B service adj transition for 2GB or less memory
            setprop ro.sys.fw.bservice_enable true
            setprop ro.sys.fw.bservice_limit 5
            setprop ro.sys.fw.bservice_age 5000
            #Enable Delay Service Restart
            setprop ro.am.reschedule_service true
        fi
        if [ "$ProductName" == "msm8952_32" ] || [ "$ProductName" == "msm8952_32_LMT" ]; then
            echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
            echo 53059 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
        elif [ "$ProductName" == "msm8952_64" ] || [ "$ProductName" == "msm8952_64_LMT" ]; then
            echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
            echo 81250 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
            if [ $MemTotal -le 2097152 ]; then
                chmod 660 /sys/module/lowmemorykiller/parameters/minfree
                echo "14746,18432,22118,25805,40000,55000" > /sys/module/lowmemorykiller/parameters/minfree
            fi
            #Set background app limit to 60 for 64 bit config with memory greater than 3.5 GB
            #Also set swappiness to 60
            #Disable process reclaim on 64 bit config with memory greater than 3.5 GB
            if [ $MemTotal -gt 3670016 ]; then
                setprop ro.sys.fw.bg_apps_limit 60
                echo 60 > /proc/sys/vm/swappiness
                echo 0 > /sys/module/process_reclaim/parameters/enable_process_reclaim
            fi
        fi

	#enable rps static configuration
        echo 1 > /sys/class/net/rmnet_ipa0/queues/rx-0/rps_cpus

        if [ -f /sys/devices/soc0/soc_id ]; then
            soc_id=`cat /sys/devices/soc0/soc_id`
        else
            soc_id=`cat /sys/devices/system/soc/soc0/id`
        fi
        case "$soc_id" in
            "264" | "289")
                # Apply Scheduler and Governor settings for 8952

                # HMP scheduler settings
                echo 2 > /proc/sys/kernel/sched_window_stats_policy
                echo 3 > /proc/sys/kernel/sched_ravg_hist_size
                echo 20000000 > /proc/sys/kernel/sched_ravg_window

                # HMP Task packing settings
                echo 20 > /proc/sys/kernel/sched_small_task
                echo 30 > /sys/devices/system/cpu/cpu0/sched_mostly_idle_load
                echo 30 > /sys/devices/system/cpu/cpu1/sched_mostly_idle_load
                echo 30 > /sys/devices/system/cpu/cpu2/sched_mostly_idle_load
                echo 30 > /sys/devices/system/cpu/cpu3/sched_mostly_idle_load
                echo 30 > /sys/devices/system/cpu/cpu4/sched_mostly_idle_load
                echo 30 > /sys/devices/system/cpu/cpu5/sched_mostly_idle_load
                echo 30 > /sys/devices/system/cpu/cpu6/sched_mostly_idle_load
                echo 30 > /sys/devices/system/cpu/cpu7/sched_mostly_idle_load

                echo 3 > /sys/devices/system/cpu/cpu0/sched_mostly_idle_nr_run
                echo 3 > /sys/devices/system/cpu/cpu1/sched_mostly_idle_nr_run
                echo 3 > /sys/devices/system/cpu/cpu2/sched_mostly_idle_nr_run
                echo 3 > /sys/devices/system/cpu/cpu3/sched_mostly_idle_nr_run
                echo 3 > /sys/devices/system/cpu/cpu4/sched_mostly_idle_nr_run
                echo 3 > /sys/devices/system/cpu/cpu5/sched_mostly_idle_nr_run
                echo 3 > /sys/devices/system/cpu/cpu6/sched_mostly_idle_nr_run
                echo 3 > /sys/devices/system/cpu/cpu7/sched_mostly_idle_nr_run

                echo 0 > /sys/devices/system/cpu/cpu0/sched_prefer_idle
                echo 0 > /sys/devices/system/cpu/cpu1/sched_prefer_idle
                echo 0 > /sys/devices/system/cpu/cpu2/sched_prefer_idle
                echo 0 > /sys/devices/system/cpu/cpu3/sched_prefer_idle
                echo 0 > /sys/devices/system/cpu/cpu4/sched_prefer_idle
                echo 0 > /sys/devices/system/cpu/cpu5/sched_prefer_idle
                echo 0 > /sys/devices/system/cpu/cpu6/sched_prefer_idle
                echo 0 > /sys/devices/system/cpu/cpu7/sched_prefer_idle

                echo 0 > /proc/sys/kernel/sched_boost

                for devfreq_gov in /sys/class/devfreq/qcom,mincpubw*/governor
                do
                    echo "cpufreq" > $devfreq_gov
                done

                for devfreq_gov in /sys/class/devfreq/0.qcom,cpubw/governor
                do
                    echo "bw_hwmon" > $devfreq_gov
                    for cpu_io_percent in /sys/class/devfreq/0.qcom,cpubw/bw_hwmon/io_percent
                    do
                        echo 20 > $cpu_io_percent
                    done
                    for cpu_guard_band in /sys/class/devfreq/0.qcom,cpubw/bw_hwmon/guard_band_mbps
                    do
                        echo 30 > $cpu_guard_band
                    done
                done

                for gpu_bimc_io_percent in /sys/class/devfreq/qcom,gpubw*/bw_hwmon/io_percent
                do
                    echo 40 > $gpu_bimc_io_percent
                done
                # disable thermal & BCL core_control to update interactive gov settings
                echo 0 > /sys/module/msm_thermal/core_control/enabled
                for mode in /sys/devices/soc.0/qcom,bcl.*/mode
                do
                    echo -n disable > $mode
                done
                for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
                do
                    bcl_hotplug_mask=`cat $hotplug_mask`
                    echo 0 > $hotplug_mask
                done
                for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
                do
                    bcl_soc_hotplug_mask=`cat $hotplug_soc_mask`
                    echo 0 > $hotplug_soc_mask
                done
                for mode in /sys/devices/soc.0/qcom,bcl.*/mode
                do
                    echo -n enable > $mode
                done

                # enable governor for perf cluster
                echo 1 > /sys/devices/system/cpu/cpu0/online
                echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
                echo "25000 1100000:50000 1300000:25000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
                echo 99 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
                echo 30000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
                echo 960000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
                echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
                echo "63 500000:85 850000:80 1000000:95" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
                echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
                echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/sampling_down_factor
                echo 499200 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

                # enable governor for power cluster
                echo 1 > /sys/devices/system/cpu/cpu4/online
                echo "interactive" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
                echo "25000 800000:50000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
                echo 90 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
                echo 30000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
                echo 806400 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
                echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
                echo "85 800000:90" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
                echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
                echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/sampling_down_factor
                echo 403200 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq

                # Bring up all cores online
                echo 1 > /sys/devices/system/cpu/cpu1/online
                echo 1 > /sys/devices/system/cpu/cpu2/online
                echo 1 > /sys/devices/system/cpu/cpu3/online
                echo 1 > /sys/devices/system/cpu/cpu4/online
                echo 1 > /sys/devices/system/cpu/cpu5/online
                echo 1 > /sys/devices/system/cpu/cpu6/online
                echo 1 > /sys/devices/system/cpu/cpu7/online

                # Enable Low power modes
                echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled

                # HMP scheduler (big.Little cluster related) settings
                echo 93 > /proc/sys/kernel/sched_upmigrate
                echo 83 > /proc/sys/kernel/sched_downmigrate

                # Enable sched guided freq control
                echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
                echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
                echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
                echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
                echo 50000 > /proc/sys/kernel/sched_freq_inc_notify
                echo 50000 > /proc/sys/kernel/sched_freq_dec_notify

                # Enable core control
                insmod /system/lib/modules/core_ctl.ko
                echo 4 > /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
                echo 4 > /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
                echo 68 > /sys/devices/system/cpu/cpu0/core_ctl/busy_up_thres
                echo 40 > /sys/devices/system/cpu/cpu0/core_ctl/busy_down_thres
                echo 100 > /sys/devices/system/cpu/cpu0/core_ctl/offline_delay_ms
                echo 1 > /sys/devices/system/cpu/cpu0/core_ctl/is_big_cluster

                # Control daemon for XO Shutdown
                factory_mode=`getprop ro.factory.factory_binary`
                product_name=`getprop ro.product.name`
                if [ "$factory_mode" != "factory" ]; then
                    case "$product_name" in
                        c5* | on5x*)
                            jig_mode=`cat /sys/class/switch/uart3/state`
                            case "$jig_mode" in
                                1)
                                    echo "PM: JIG UART" > /dev/kmsg
                                ;;
                                0)
                                    echo "PM: stop at_distributor" > /dev/kmsg
                                    stop at_distributor
                                    stop diag_uart_log
                                ;;
                            esac
                        ;;
                    esac
                else
                    case "$product_name" in
                        c5* | on5x*)
                            # Enable core control
                            echo 2 > /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
                            echo 4 > /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
                            echo 68 > /sys/devices/system/cpu/cpu0/core_ctl/busy_up_thres
                            echo 40 > /sys/devices/system/cpu/cpu0/core_ctl/busy_down_thres
                            echo 100 > /sys/devices/system/cpu/cpu0/core_ctl/offline_delay_ms
                            echo 1 > /sys/devices/system/cpu/cpu0/core_ctl/is_big_cluster
                        ;;
                     esac
                fi

                # re-enable thermal & BCL core_control now
                echo 1 > /sys/module/msm_thermal/core_control/enabled
                for mode in /sys/devices/soc.0/qcom,bcl.*/mode
                do
                    echo -n disable > $mode
                done
                for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
                do
                    echo $bcl_hotplug_mask > $hotplug_mask
                done
                for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
                do
                    echo $bcl_soc_hotplug_mask > $hotplug_soc_mask
                done
                for mode in /sys/devices/soc.0/qcom,bcl.*/mode
                do
                    echo -n enable > $mode
                done


                # Enable dynamic clock gating
                echo 1 > /sys/module/lpm_levels/lpm_workarounds/dynamic_clock_gating
                # Enable timer migration to little cluster
                echo 1 > /proc/sys/kernel/power_aware_timer_migration
                # Change Governor parameters permission
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
                chmod -h 660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
                chmod -h 660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/lpm_disable_freq
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/lpm_disable_freq
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/lpm_disable_freq
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/lpm_disable_freq
                # Set LPM Disable Freq
                echo 2000000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/lpm_disable_freq
                echo 1094400 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/lpm_disable_freq

                # Change power debug parameters permission
                chown radio.system /sys/module/qpnp_power_on/parameters/reset_enabled
                chown radio.system /sys/module/qpnp_power_on/parameters/wake_enabled
                chown radio.system /sys/module/qpnp_int/parameters/debug_mask
                chown radio.system /sys/module/lpm_levels/parameters/secdebug
                chmod 664 /sys/module/qpnp_power_on/parameters/reset_enabled
                chmod 664 /sys/module/qpnp_power_on/parameters/wake_enabled
                chmod 664 /sys/module/qpnp_int/parameters/debug_mask
                chmod 664 /sys/module/lpm_levels/parameters/secdebug

                chown -h system.system /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
                chown -h system.system /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
                chown -h system.system /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
                chown -h system.system /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
                
                # Bus-DCVS permission settings
                chown -h system.system /sys/class/devfreq/0.qcom,cpubw/governor
                chown -h system.system /sys/class/devfreq/0.qcom,cpubw/bw_hwmon/io_percent
                chown -h system.system /sys/class/devfreq/0.qcom,cpubw/bw_hwmon/guard_band_mbps
                chown -h system.system /sys/class/devfreq/0.qcom,cpubw/polling_interval
                chown -h system.system /sys/class/devfreq/0.qcom,cpubw/max_freq
                chown -h system.system /sys/class/devfreq/0.qcom,cpubw/min_freq
                chmod -h 0660 /sys/class/devfreq/0.qcom,cpubw/governor
                chmod -h 0660 /sys/class/devfreq/0.qcom,cpubw/bw_hwmon/io_percent
                chmod -h 0660 /sys/class/devfreq/0.qcom,cpubw/bw_hwmon/guard_band_mbps
                chmod -h 0660 /sys/class/devfreq/0.qcom,cpubw/polling_interval
                chmod -h 0664 /sys/class/devfreq/0.qcom,cpubw/max_freq
                chmod -h 0664 /sys/class/devfreq/0.qcom,cpubw/min_freq

            ;;
            *)
                panel=`cat /sys/class/graphics/fb0/modes`
                if [ "${panel:5:1}" == "x" ]; then
                    panel=${panel:2:3}
                else
                    panel=${panel:2:4}
                fi

                # Apply Scheduler and Governor settings for 8976
                # SoC IDs are 266, 274, 277, 278

                # HMP scheduler (big.Little cluster related) settings
                echo 95 > /proc/sys/kernel/sched_upmigrate
                echo 85 > /proc/sys/kernel/sched_downmigrate
                echo 1 > /proc/sys/kernel/sched_boot_complete

                if [ $panel -gt 1080 ]; then
                    echo 2 > /proc/sys/kernel/sched_window_stats_policy
                    echo 5 > /proc/sys/kernel/sched_ravg_hist_size
                else
                    echo 3 > /proc/sys/kernel/sched_window_stats_policy
                    echo 3 > /proc/sys/kernel/sched_ravg_hist_size

                    echo 0 > /sys/devices/system/cpu/cpu0/sched_prefer_idle
                    echo 0 > /sys/devices/system/cpu/cpu1/sched_prefer_idle
                    echo 0 > /sys/devices/system/cpu/cpu2/sched_prefer_idle
                    echo 0 > /sys/devices/system/cpu/cpu3/sched_prefer_idle
                    echo 0 > /sys/devices/system/cpu/cpu4/sched_prefer_idle
                    echo 0 > /sys/devices/system/cpu/cpu5/sched_prefer_idle
                    echo 0 > /sys/devices/system/cpu/cpu6/sched_prefer_idle
                    echo 0 > /sys/devices/system/cpu/cpu7/sched_prefer_idle
                fi

                echo 3 > /sys/devices/system/cpu/cpu0/sched_mostly_idle_nr_run
                echo 3 > /sys/devices/system/cpu/cpu1/sched_mostly_idle_nr_run
                echo 3 > /sys/devices/system/cpu/cpu2/sched_mostly_idle_nr_run
                echo 3 > /sys/devices/system/cpu/cpu3/sched_mostly_idle_nr_run
                echo 3 > /sys/devices/system/cpu/cpu4/sched_mostly_idle_nr_run
                echo 3 > /sys/devices/system/cpu/cpu5/sched_mostly_idle_nr_run
                echo 3 > /sys/devices/system/cpu/cpu6/sched_mostly_idle_nr_run
                echo 3 > /sys/devices/system/cpu/cpu7/sched_mostly_idle_nr_run
                echo 0 > /sys/block/mmcblk0/queue/iosched/slice_idle

                # Bus-DCVS permission settings
                echo "bw_hwmon" > /sys/class/devfreq/0.qcom,cpubw/governor
                chown -h system.system /sys/class/devfreq/0.qcom,cpubw/governor
                chown -h system.system /sys/class/devfreq/0.qcom,cpubw/bw_hwmon/io_percent
                chown -h system.system /sys/class/devfreq/0.qcom,cpubw/bw_hwmon/guard_band_mbps
                chown -h system.system /sys/class/devfreq/0.qcom,cpubw/polling_interval
                chown -h system.system /sys/class/devfreq/0.qcom,cpubw/max_freq
                chown -h system.system /sys/class/devfreq/0.qcom,cpubw/min_freq
                chmod -h 0660 /sys/class/devfreq/0.qcom,cpubw/governor
                chmod -h 0660 /sys/class/devfreq/0.qcom,cpubw/bw_hwmon/io_percent
                chmod -h 0660 /sys/class/devfreq/0.qcom,cpubw/bw_hwmon/guard_band_mbps
                chmod -h 0660 /sys/class/devfreq/0.qcom,cpubw/polling_interval
                chmod -h 0664 /sys/class/devfreq/0.qcom,cpubw/max_freq
                chmod -h 0664 /sys/class/devfreq/0.qcom,cpubw/min_freq


                for devfreq_gov in /sys/class/devfreq/qcom,mincpubw*/governor
                do
                    echo "powersave" > $devfreq_gov
                done

                for devfreq_gov in /sys/class/devfreq/0.qcom,cpubw/governor
                do
                    echo "bw_hwmon" > $devfreq_gov
                    for cpu_io_percent in /sys/class/devfreq/0.qcom,cpubw/bw_hwmon/io_percent
                    do
                        echo 20 > $cpu_io_percent
                    done
                    for cpu_guard_band in /sys/class/devfreq/0.qcom,cpubw/bw_hwmon/guard_band_mbps
                    do
                        echo 30 > $cpu_guard_band
                    done
                done

                for gpu_bimc_io_percent in /sys/class/devfreq/qcom,gpubw*/bw_hwmon/io_percent
                do
                    echo 40 > $gpu_bimc_io_percent
                done
                # disable thermal & BCL core_control to update interactive gov settings
                echo 0 > /sys/module/msm_thermal/core_control/enabled
                for mode in /sys/devices/soc.0/qcom,bcl.*/mode
                do
                    echo -n disable > $mode
                done
                for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
                do
                    bcl_hotplug_mask=`cat $hotplug_mask`
                    echo 0 > $hotplug_mask
                done
                for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
                do
                    bcl_soc_hotplug_mask=`cat $hotplug_soc_mask`
                    echo 0 > $hotplug_soc_mask
                done
                for mode in /sys/devices/soc.0/qcom,bcl.*/mode
                do
                    echo -n enable > $mode
                done

                # enable governor for power cluster
                echo 1 > /sys/devices/system/cpu/cpu0/online
                echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
                echo 90 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
                echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
                echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
                echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
                echo 691200 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

                # enable governor for perf cluster
                echo 1 > /sys/devices/system/cpu/cpu4/online
                echo "interactive" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
                echo 85 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
                echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
                echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
                echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
                echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/sampling_down_factor
                echo 883200 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
                echo 19000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis

                # sysfs governor permissions for power cluster
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/align_windows
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/boost
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
                chown -h system.system /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/align_windows
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/boost
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
                chmod -h 0660 /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load

                # sysfs governor permissions for perf cluster
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/align_windows
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/boost
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
                chown -h system.system /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/align_windows
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/boost
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
                chmod -h 0660 /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load

                if [ $panel -gt 1080 ]; then
                    echo 19000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
                    echo 1017600 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
                    echo "80" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
                    echo 1382400 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
                    echo "19000 1382400:39000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
                    echo "85 1382400:90 1747200:80" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
                    # HMP Task packing settings for 8976
                    echo 30 > /proc/sys/kernel/sched_small_task
                    echo 20 > /sys/devices/system/cpu/cpu0/sched_mostly_idle_load
                    echo 20 > /sys/devices/system/cpu/cpu1/sched_mostly_idle_load
                    echo 20 > /sys/devices/system/cpu/cpu2/sched_mostly_idle_load
                    echo 20 > /sys/devices/system/cpu/cpu3/sched_mostly_idle_load
                    echo 20 > /sys/devices/system/cpu/cpu4/sched_mostly_idle_load
                    echo 20 > /sys/devices/system/cpu/cpu5/sched_mostly_idle_load
                    echo 20 > /sys/devices/system/cpu/cpu6/sched_mostly_idle_load
                    echo 20 > /sys/devices/system/cpu/cpu7/sched_mostly_idle_load
                    #set texture cache size for resolution greater than 1080p
                    setprop ro.hwui.texture_cache_size 72
                else
                    echo 39000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
                    echo 806400 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
                    echo "1 691200:90" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
                    echo 1190400 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
                    echo "19000 1190400:39000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
                    echo "85 1190400:90 1747200:80" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
                    # HMP Task packing settings for 8976
                    echo 20 > /proc/sys/kernel/sched_small_task
                    echo 30 > /sys/devices/system/cpu/cpu0/sched_mostly_idle_load
                    echo 30 > /sys/devices/system/cpu/cpu1/sched_mostly_idle_load
                    echo 30 > /sys/devices/system/cpu/cpu2/sched_mostly_idle_load
                    echo 30 > /sys/devices/system/cpu/cpu3/sched_mostly_idle_load
                    echo 30 > /sys/devices/system/cpu/cpu4/sched_mostly_idle_load
                    echo 30 > /sys/devices/system/cpu/cpu5/sched_mostly_idle_load
                    echo 30 > /sys/devices/system/cpu/cpu6/sched_mostly_idle_load
                    echo 30 > /sys/devices/system/cpu/cpu7/sched_mostly_idle_load
                fi

                echo 0 > /proc/sys/kernel/sched_boost

                # Bring up all cores online
                echo 1 > /sys/devices/system/cpu/cpu1/online
                echo 1 > /sys/devices/system/cpu/cpu2/online
                echo 1 > /sys/devices/system/cpu/cpu3/online
                echo 1 > /sys/devices/system/cpu/cpu4/online
                echo 1 > /sys/devices/system/cpu/cpu5/online
                echo 1 > /sys/devices/system/cpu/cpu6/online
                echo 1 > /sys/devices/system/cpu/cpu7/online

                #Disable CPU retention modes for 32bit builds
                ProductName=`getprop ro.product.name`
                if [ "$ProductName" == "msm8952_32" ] || [ "$ProductName" == "msm8952_32_LMT" ]; then
                    echo N > /sys/module/lpm_levels/system/a72/cpu4/retention/idle_enabled
                    echo N > /sys/module/lpm_levels/system/a72/cpu5/retention/idle_enabled
                    echo N > /sys/module/lpm_levels/system/a72/cpu6/retention/idle_enabled
                    echo N > /sys/module/lpm_levels/system/a72/cpu7/retention/idle_enabled
                fi

		if [ `cat /sys/devices/soc0/revision` == "1.0" ]; then
		    # Disable l2-pc and l2-gdhs low power modes
		    echo N > /sys/module/lpm_levels/system/a53/a53-l2-gdhs/idle_enabled
		    echo N > /sys/module/lpm_levels/system/a72/a72-l2-gdhs/idle_enabled
		    echo N > /sys/module/lpm_levels/system/a53/a53-l2-pc/idle_enabled
		    echo N > /sys/module/lpm_levels/system/a72/a72-l2-pc/idle_enabled
		fi

                # Enable LPM Prediction
                echo 1 > /sys/module/lpm_levels/parameters/lpm_prediction

                # Enable Low power modes
                echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled
                # Disable L2 GDHS on 8976
                echo N > /sys/module/lpm_levels/system/a53/a53-l2-gdhs/idle_enabled
                echo N > /sys/module/lpm_levels/system/a72/a72-l2-gdhs/idle_enabled

                # Enable sched guided freq control
                echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
                echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
                echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
                echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
                echo 50000 > /proc/sys/kernel/sched_freq_inc_notify
                echo 50000 > /proc/sys/kernel/sched_freq_dec_notify

                # Enable core control
                insmod /system/lib/modules/core_ctl.ko
                #for 8976
                echo 2 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
                echo 4 > /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
                echo 68 > /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
                echo 40 > /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
                echo 100 > /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
                echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster

                # re-enable thermal & BCL core_control now
                echo 1 > /sys/module/msm_thermal/core_control/enabled
                for mode in /sys/devices/soc.0/qcom,bcl.*/mode
                do
                    echo -n disable > $mode
                done
                for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
                do
                    echo $bcl_hotplug_mask > $hotplug_mask
                done
                for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
                do
                    echo $bcl_soc_hotplug_mask > $hotplug_soc_mask
                done
                for mode in /sys/devices/soc.0/qcom,bcl.*/mode
                do
                    echo -n enable > $mode
                done
                chown -h system.system /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
                chown -h system.system /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
                chown -h system.system /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
                chown -h system.system /sys/devices/system/cpu/cpu4/core_ctl/max_cpus

                # Change power debug parameters permission
                chown radio.system /sys/module/qpnp_power_on/parameters/reset_enabled
                chown radio.system /sys/module/qpnp_power_on/parameters/wake_enabled
                chown radio.system /sys/module/qpnp_int/parameters/debug_mask
                chown radio.system /sys/module/lpm_levels/parameters/secdebug
                chmod 664 /sys/module/qpnp_power_on/parameters/reset_enabled
                chmod 664 /sys/module/qpnp_power_on/parameters/wake_enabled
                chmod 664 /sys/module/qpnp_int/parameters/debug_mask
                chmod 664 /sys/module/lpm_levels/parameters/secdebug

                # Enable timer migration to little cluster
                echo 1 > /proc/sys/kernel/power_aware_timer_migration

                # Control daemon for XO Shutdown
                factory_mode=`getprop ro.factory.factory_binary`
                product_name=`getprop ro.product.name`
                if [ "$factory_mode" != "factory" ]; then
                    case "$product_name" in
                        a9* | gts2* | c9*)
                            jig_mode=`cat /sys/class/switch/uart3/state`
                            case "$jig_mode" in
                                1)
                                    echo "PM: JIG UART" > /dev/kmsg
                                ;;
                                0)
                                    echo "PM: stop at_distributor" > /dev/kmsg
                                    stop at_distributor
                                    stop diag_uart_log
                                ;;
                            esac
                        ;;
                    esac
                fi

		case "$soc_id" in
			"277" | "278")
			# Start energy-awareness for 8976
			start energy-awareness
		;;
		esac

		#enable sched colocation and colocation inheritance
		echo 130 > /proc/sys/kernel/sched_grp_upmigrate
		echo 110 > /proc/sys/kernel/sched_grp_downmigrate
		echo   1 > /proc/sys/kernel/sched_enable_thread_grouping
            ;;
        esac
    ;;
esac

chown -h system /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
chown -h system /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
chown -h system /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy

emmc_boot=`getprop ro.boot.emmc`
case "$emmc_boot"
    in "true")
        chown -h system /sys/devices/platform/rs300000a7.65536/force_sync
        chown -h system /sys/devices/platform/rs300000a7.65536/sync_sts
        chown -h system /sys/devices/platform/rs300100a7.65536/force_sync
        chown -h system /sys/devices/platform/rs300100a7.65536/sync_sts
    ;;
esac

# Post-setup services
case "$target" in
    "msm8952")
        rm /data/system/perfd/default_values
        start perfd
    ;;
esac


#Set texture_cache_size property if not defined
if [ -z `getprop ro.hwui.texture_cache_size` ]; then
   setprop ro.hwui.texture_cache_size 40
fi

if [ -f /sys/devices/soc0/select_image ]; then
    # Let kernel know our image version/variant/crm_version
    image_version="10:"
    image_version+=`getprop ro.build.id`
    image_version+=":"
    image_version+=`getprop ro.build.version.incremental`
    image_variant=`getprop ro.product.name`
    image_variant+="-"
    image_variant+=`getprop ro.build.type`
    oem_version=`getprop ro.build.version.codename`
    echo 10 > /sys/devices/soc0/select_image
    echo $image_version > /sys/devices/soc0/image_version
    echo $image_variant > /sys/devices/soc0/image_variant
    echo $oem_version > /sys/devices/soc0/image_crm_version
fi

echo 1 > /sys/devices/system/cpu/cpufreq/cpufreq_boot_limit_period
