# QUALCOMM POWERALL - power logging console
# 
# v1.2
#


#/*capture at every 1 second*/
interval=3
#/*total cycles*/
cycles=5
#/*delay time before capturing*/
delay_time=4

#/*capture basic information, dmesg, logcat ... dump, save to data/powerall/basic_information_dump.txt and others*/
function basic_process()
{
	start_time=$(date +%s);
	echo "Start basic_process ...";
	rm -rf /data/powerall/basic_information_dump.txt;
	rm -rf /data/powerall/ps_dump.txt;
	rm -rf /data/powerall/dmesg_dump.txt;
	rm -rf /data/powerall/logcat_dump.txt
	#/*Time*/
	echo Date Time: `date +%Y-%m-%d%t%X` > /data/powerall/basic_information_dump.txt
	#/*Build*/
	echo Build: `cat /firmware/verinfo/ver_info.txt` >> /data/powerall/basic_information_dump.txt
	#/*Linux version*/
	echo Linux version: `cat /proc/version` >> /data/powerall/basic_information_dump.txt
	#/*Serial number*/
	echo Serial number: `getprop ro.serialno` >> /data/powerall/basic_information_dump.txt
	#/*Hardware*/
	echo Hardware: `getprop ro.hardware` >> /data/powerall/basic_information_dump.txt
	#/*backlight*/
	echo lcd_brightness: `cat /sys/class/leds/lcd-backlight/brightness` >> /data/powerall/basic_information_dump.txt
	#/*charging or not?*/
	echo charging?: `cat /sys/class/power_supply/battery/status` >> /data/powerall/basic_information_dump.txt
	#/*governor*/
	echo CPU0 governor : `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor` >> /data/powerall/basic_information_dump.txt
	echo CPU1 governor : `cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor` >> /data/powerall/basic_information_dump.txt
	#/*cmdline*/
	echo "cmdline :" >> /data/powerall/basic_information_dump.txt
	echo `cat /proc/cmdline` >> /data/powerall/basic_information_dump.txt

	#/* Scheduler parameters */
	cd /proc/sys/kernel/;
	echo "" >> /data/powerall/basic_information_dump.txt
	echo \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\- Scheduler \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\- >> /data/powerall/basic_information_dump.txt
	for i in *; do if [[ $i == sched_* ]]; then echo $i \=\ `cat $i`; fi; done >> /data/powerall/basic_information_dump.txt
	cd /;

	#/* Governor parameters */
	cd /sys/devices/system/cpu/;
	echo "" >> /data/powerall/basic_information_dump.txt
	echo \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\- Governor \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\- >> /data/powerall/basic_information_dump.txt
	for i in 0 1 2 3 4 5 6 7 8 9; 
	do if [ -d cpu$i/cpufreq/interactive ]; 
	then 
		cd cpu$i/cpufreq/interactive;
		for j in *; do echo cpu$i/cpufreq/interactive/$j \=\ `cat $j`; done >> /data/powerall/basic_information_dump.txt;
		cd ../../../;
	fi;
	done
	cd /;

	#/* ps */
	ps > /data/powerall/ps_dump.txt
	#/*	ps-thread*/
	ps -t > /data/powerall/ps-thread_dump.txt
	#/* dmesg */
	dmesg > /data/powerall/dmesg_dump.txt
	#/* logcat */
	logcat -f /data/powerall/logcat_dump.txt -d
	#/* dumpsys power */
	dumpsys power > /data/powerall/dumpsys_power.txt
	#/* dumpsys alarm*/
	dumpsys alarm > /data/powerall/dumpsys_power.txt

	end_time=$(date +%s);
	echo "Finished basic_process spent $(($end_time - $start_time))s, log in /data/powerall";
}

#/*capture top and powertop dump, save to data/powerall/dumptop.txt*/
function top_process()
{
    j=0
	start_time=$(date +%s);
    powertop_file="/data/powertop"
    if [ ! -e "$powertop_file" ]; then
      echo "no powertop in /data/ !!!, please copy one";
      echo "no powertop in /data/ !!!, please copy one" > data/powerall/dumptop.txt
      echo "Start top_process ...";
		while (($j<$cycles))
		  do
		    echo \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\= top \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=;
		    cat /proc/uptime;
		    top -m 25 -d 1 -n 1 -t;
		    j=$(($j+1))
		done > /data/powerall/dumptop.txt
		end_time=$(date +%s);
      echo "Finished top_process spent $(($end_time - $start_time))s, log in /data/powerall";	  
	else
		echo "Start top_process ...";
		while (($j<$cycles))
		  do
		    echo \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\= top \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=;
		    cat /proc/uptime;
		    top -m 25 -d 1 -n 1 -t;
		    echo \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\- powertop \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-;
		    /data/powertop -r -d -t 5
		j=$(($j+1))
		done > /data/powerall/dumptop.txt
		end_time=$(date +%s);
		echo "Finished top_process spent $(($end_time - $start_time))s, log in /data/powerall";
	fi
}

#/*capture clock and LDO dump, save to /data/powerall/clk_ldo_dump.txt*/
function clk_ldo_process()
{
    j=0
	start_time=$(date +%s);
	echo "clk_ldo_process Started ...";
	while(($j<$cycles))
	do
        echo \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\ clock =\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=;
        cat /proc/uptime;
		cat /d/clk/enabled_clocks;
#        cd /sys/kernel/debug/clk;
#        for i in *;
#          do 
#		  if [ -d $i ];
#          then if [ "$(cat $i/enable)" == "1" ];
#              then if [ -e $i/measure ];
#                then 
#                  echo $i \=\> enable:`cat $i/enable` measure:`cat $i/measure`;
#				else
#                  echo $i \=\> enable:`cat $i/enable` rate:`cat $i/rate`;
#                fi;
#            fi;
#          fi;
#        done;
       echo \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\- LDO \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-;
       cd /sys/class/regulator;
	   for i in *;
	   do if [ -d $i ];
    	   then if [ -e $i/state ];
		     then if [ "$(cat $i/state)" == "enabled" ];
			   then if [ -e $i/microvolts ];
			     then echo $i \=\> name:`cat $i/name` state:`cat $i/state` microvolt:`cat $i/microvolts`;
				 else echo $i \=\> name:`cat $i/name` state:`cat $i/state` microvolt: N\/A; 
				 fi; 
				fi;
			  fi; 
			fi; 
		done; 
    sleep $interval;
	j=$(($j+1))
	done > /data/powerall/clk_ldo_dump.txt
	end_time=$(date +%s);
    echo "Finished clk_ldo_process spent $(($end_time - $start_time))s, log in /data/powerall";
}

#/* capture wakelock,interrupt,wakeup_sources dump, save to data/powerall/wake_int_dump.txt */
function wake_process()
{
    j=0
	start_time=$(date +%s);
	echo "wake_process Started ...";
	while (($j<$cycles))
	  do
		echo \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\= wakeup_sources \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=;
		cat /proc/uptime;
		#for example : cat wakeup_sources | grep msm_otg
		# msm_otg         6               6               0               0               52445
		# active_since = 52445 (52s) , msm_otg vote against system sleep 52s.
		cat /sys/kernel/debug/wakeup_sources
		echo \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\- wakelocks \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-;
		cat /sys/power/wake_lock
		echo \~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~ interrupts \~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~;
		cat /proc/interrupts
    sleep $interval;
	j=$(($j+1))
	done > /data/powerall/wake_int_dump.txt
	end_time=$(date +%s);
	echo "finished wake_process spent $(($end_time - $start_time))s, log in /data/powerall";
}

#/* capture lpm state, c-state, save to data/powerall/lpmstat.txt */
function lpm_process()
{
    j=0
	start_time=$(date +%s);
	echo "lpm_process Started ..."

	rm -rf data/powerall/lpmstat.txt;
	#/*print */
	echo \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\= rpm_stats \- indicate XO and Vddmin \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\= > /data/powerall/lpmstat.txt
	cat /sys/kernel/debug/rpm_stats >> /data/powerall/lpmstat.txt ;
	echo "";
	echo "";
	echo \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\= CPU LPM stats \- how to read the lpm_stats ? \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\= >> /data/powerall/lpmstat.txt
	echo "# for example :" >> /data/powerall/lpmstat.txt
	echo "# [cpu 1] idle-standalone-power-collapse:" >> /data/powerall/lpmstat.txt
	echo "# count: 442  - > cpu1 did idle standalone power collapse 442 times" >> /data/powerall/lpmstat.txt
	echo "# total_time: 58.404528498  - > since it was reset (or since boot) the total time spent in standalone idle pc by cpu1 is 58.40 secs" >> /data/powerall/lpmstat.txt
	echo "# 0.000062500: 0 (0-0)" >> /data/powerall/lpmstat.txt
	echo "# 0.000250000: 6 (122020-243997)" >> /data/powerall/lpmstat.txt
	echo "# 0.001000000: 14 (305014-366058)" >> /data/powerall/lpmstat.txt
	echo "# 0.004000000: 6 (1647490-3356933)" >> /data/powerall/lpmstat.txt
	echo "# 0.016000000: 110 (7598876-15469537)" >> /data/powerall/lpmstat.txt
	echo "# 0.064000000: 226 (18737793-60237629)  - > for time less than 0.64s and greater than 0.016s, the number of times cpu1 did standalone PC was 226" >> /data/powerall/lpmstat.txt
	echo \~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~ lpmstat in 10s \~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~\ >> /data/powerall/lpmstat.txt

	echo reset > /d/lpm_stats/stats;
	sleep 10;
	cat /d/lpm_stats/stats >> /data/powerall/lpmstat.txt
	end_time=$(date +%s);
	echo "finished lpm_process spent $(($end_time - $start_time))s, log in /data/powerall/";
}

#/* capture rpm logs, save to data/powerall */
function rpm_process()
{
	start_time=$(date +%s);
	echo "rpm_process Started ...";
	cd /;
	rm -rf /data/powerall/rpm_log.bin;
	cat d/rpm_log > /data/powerall/rpm_log.bin &

	#/*kill the above thread after 4s*/
	latest=$!; 
	echo $latest;
	sleep 4 && kill -9 $latest
	end_time=$(date +%s);
	echo "finished rpm_process spent $(($end_time - $start_time))s, log in /data/powerall/"
}

#/* capture irq unmask dmesg, save to data/powerall */
function dmesg_process()
{
	start_time=$(date +%s);
	echo "dmesg_process Started ...";
	
	dmesg -c > /data/powerall/temp.txt ;
	rm -rf /data/powerall/temp.txt ;
	echo 1 > /sys/module/msm_show_resume_irq/parameters/debug_mask ;
	sleep 10;
	dmesg -r  > /data/powerall/unmask_irq_dmesg.txt

	end_time=$(date +%s);
	echo "finished dmesg_process spent $(($end_time - $start_time))s, log in /data/powerall/"
}

#/* TCPIP dump, save to data/powerall */
function tcp_process()
{
	start_time=$(date +%s);
	echo "tcp_process Started ...";

	tcpdump -i any -s 0 -w /data/powerall/tcpdump.pcap &
	#/*kill the above thread after 4s*/
	latest=$!; 
	echo $latest;
	#/*sleep arg1 s then kill the thread*/
	sleep $1 && kill -9 $latest
	end_time=$(date +%s);
	echo "finished tcp_process spent $(($end_time - $start_time))s, log in /data/powerall/"
}

#/* Tracing dump, save to data/powerall */
function tracing_process()
{
	start_time=$(date +%s);
	echo "tracing_process Started ...";
	if [ "$(cat /d/tracing/buffer_total_size_kb)" > "130000" ]; then
		rm -rf /data/powerall/ftrace.txt && echo 130000 > /d/tracing/buffer_size_kb && echo "" > /d/tracing/set_event && echo "" > /d/tracing/trace && echo "irq:* sched:* power:* msm_low_power:* kgsl:* " > /d/tracing/set_event && echo 1 > /d/tracing/tracing_on && sleep 10 && echo 0 > /d/tracing/tracing_on && cat /d/tracing/trace > /data/powerall/ftrace.txt
    else
	    rm -rf /data/powerall/ftrace.txt && echo `cat /d/tracing/buffer_total_size_kb` > /d/tracing/buffer_size_kb && echo "" > /d/tracing/set_event && echo "" > /d/tracing/trace && echo "irq:* sched:* power:* msm_low_power:* kgsl:* " > /d/tracing/set_event && echo 1 > /d/tracing/tracing_on && sleep 10 && echo 0 > /d/tracing/tracing_on && cat /d/tracing/trace > /data/powerall/ftrace.txt
    fi
	end_time=$(date +%s);
	echo "finished tracing_process spent $(($end_time - $start_time))s, log in /data/powerall/"
}

#/* Thermal dump, save to data/powerall */
function thermal_process()
{
  start_time=$(date +%s);

  cat /sys/class/thermal/*/type
  
  cat /sys/class/thermal/*/temp
  
  end_time=$(date +%s);
  echo "finished thermal_process spent $(($end_time - $start_time))s, log in /data/powerall/"
}

function fps_process()
{
	logcat -c;
	start_time=$(date +%s);
	echo "fps_process Started ...";
	echo "\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\= fps_sources \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=" >/data/powerall/fps_process_log.txt;
	logcat -v time | grep PROFILE_VIDEO > /data/powerall/fps_process_log.txt&
	latest=$!;
	echo $latest;
	sleep 4 && kill -9 $latest
	end_time=$(date +%s);
	echo "finished fps_process spent $(($end_time - $start_time))s, log in /data/powerall";
}


function all_process()
{
    echo "Needs 126s";
	echo "Start after $delay_time s , you can remove USB";
	sleep $delay_time;
    basic_process;
	top_process;
	clk_ldo_process;
	wake_process;
	lpm_process;
	rpm_process;
	dmesg_process;
	tcp_process 10;
	tracing_process;
	thermal_process;
	fps_process;
    echo "finished dump all";
}

#/*main process*/
logPath="/data/powerall"
cd /
if [ ! -d "$logPath" ]; then
mkdir "$logPath"
fi

echo "#######################################################";
echo "#               QUALCOMM POWERALL V1.2                #";
echo "#               power logging console                 #";
echo "#                                                     #";
echo "#    please report issues to powerall.hotline         #";
echo "#######################################################";
echo "";
echo "0. Basic information dump"
echo "1. Top and powertop dump";
echo "2. Clock and LDO dump";
echo "3. Wakelock,interrupt,wakeup_sources dump";
echo "4. Lpm state, c-state and XO,Vddmin dump";
echo "5. rpm log dump";
echo "6. irq unmask dmesg";
echo "7. Display power dump";
echo "8. Audio power dump";
echo "9. Graphic power dump";
echo "10. Video power dump";
echo "11. Camera power dump";
echo "12. TCPIP dump";
echo "13. Tracing log dump";
echo "14. Thermal dump"
echo "15. fps_process"
echo "a. Dump all";
echo "q. Quit";
echo "please enter a number :";	
read -r number

case $number in

0)
	echo "Need $((3+3))s";
	echo "Start after $delay_time s , you can remove USB";
	sleep $delay_time;
	basic_process;
	;;
1)
	echo "Need $$((7*cycles+3))s";
	echo "Start after $delay_time s , you can remove USB";
	sleep $delay_time;
	top_process;
	;;
2)
	echo "Need 21s";
	echo "Start after $delay_time s , you can remove USB";
	sleep $delay_time && clk_ldo_process &
	;;
3)
	echo "Need 13s";
	echo "Start after $delay_time s , you can remove USB";
	sleep $delay_time;
    wake_process;
	;;
4)
	echo "Need 4s";
	echo "Start after $delay_time s , you can remove USB";
	sleep $delay_time;
    lpm_process;
	;;
5)
	echo "Need 4s";
	echo "Start after $delay_time s, you can remove USB";
	sleep $delay_time;
    rpm_process;
	;;
6)
	echo "Need 15s";
	echo "Start after $delay_time s, you can remove USB";
	sleep $delay_time;
    dmesg_process;
	;;
12)
	echo "input seconds :";	
	read -r seconds
	echo "Start after $delay_time s, you can remove USB";
	sleep $delay_time;
    tcp_process $seconds;
	;;
13)
	echo "Start after $delay_time s, you can remove USB";
	sleep $delay_time;
	tracing_process;
	;;
14)
	echo "Start after $delay_time s, you can remove USB";
	sleep $delay_time;
	thermal_process;
	;;
15)
	echo "Start after $delay_time s, you can remove USB";
	sleep $delay_time;
	fps_process;
	;;
a)
	echo "dump all";
    if [ ! -e "/data/powertop" ]; then
      echo "no powertop in /data/ !!!, do you want to continue? Y or N";
      read -r input
	    if [ "$input" == "Y" ] || [ "$input" == "y" ]; then
		  all_process &
		else
		  echo "";
		fi
	else
      all_process &
	fi
	  ;;
q)
	echo "q or invalid, exiting..."
	;;
esac




