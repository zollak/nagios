#!/bin/bash

devices_path="/dev"
mdstat="/proc/mdstat"
mdadm_bin="/sbin/mdadm"
megacli_bin="/usr/sbin/megacli"
arcconf_bin="/usr/sbin/arcconf"

help() {

cat << EOL

usage: check_raid {softraid|adaptec|megaraid|megaraid+bbu}

EOL
exit 0

}

softraid() {

if [ -f $mdadm_bin ]; then
	echo "No mdadm binary file found!"
	exit 3
fi

if [ -f $mdstat ]; then
        md_devices=$(cat $mdstat|grep "md[0-9]*"|awk '{ print $1 }')
        md_devices_count=$(echo $md_devices|wc -l)

        if [ $md_devices_count -eq 0 ]; then
                echo "No active softraid device found!"
                exit 3
        fi
else
        echo "File $md_devices not found!"
        exit 3
fi

detect_problem=0
for md_device in $md_devices; do
        md_details=$($mdadm_bin --detail $devices_path/$md_device|egrep "md[0-9]*|Devices|Level|State.*:")
	md_failed_dev=$(echo "$md_details"|grep "Failed"|awk -F : '{ print $2 }'|tr -d ' ')
	md_state=$(echo "$md_details"|grep "State"|awk -F : '{ print $2 }'|tr -d ' ')

	if [[ $md_failed_dev -ne 0 || "$md_state" != "clean" && "$md_state" != "active" ]]; then
		echo -n $md_details
		detect_problem=1
	fi
done

if [ $detect_problem -eq 1 ]; then
	exit 2
else
	echo "Softraid OK"
	exit 0
fi

}

bbu_info() {

	echo -n "<br>BBU status: $bbu_status"
	echo -n "<br>BBU rel state fo charge: $bbu_rc%"
	echo -n "<br>BBU capacity $bbu_dc mAh/$bbu_fc mAh; $bbu_fc_per_dc%"

}


megaraid() {

if [ ! -f $megacli_bin ]; then
	echo "No megacli binary file found!"
	exit 3
fi

raid_details=$($megacli_bin -AdpAllInfo -aALL|egrep "Virtual|Degraded|^[ ]*Offline.*|Physical Dev|Disks")
raid_degraded=$(echo "$raid_details"|grep Degraded|awk -F : '{ print $2 }'|tr -d ' ')
raid_offline=$(echo "$raid_details"|grep Offline|awk -F : '{ print $2 }'|tr -d ' ')
raid_critical=$(echo "$raid_details"|grep Critical|awk -F : '{ print $2 }'|tr -d ' ')
raid_failed=$(echo "$raid_details"|grep Failed|awk -F : '{ print $2 }'|tr -d ' ')

check_bbu=0
if [ "$1" == "bbu" ]; then
	bbu_status=$($megacli_bin -AdpBbuCmd -aAll|grep "Battery State"|awk -F : '{ print $2 }'|tr -d ' ')
	bbu_relstate_charge=$($megacli_bin -AdpBbuCmd -aAll|grep ".*Relative.*Charge:"|awk -F : '{ print $2 }'|tr -d ' '|sort|uniq)
	bbu_rc=${bbu_relstate_charge%\%}
	bbu_design_cap=$($megacli_bin -AdpBbuCmd -aAll|grep "Design Capacity"|awk -F : '{ print $2 }'|tr -d ' '|sort|uniq)
	bbu_dc=${bbu_design_cap%mAh}
	bbu_fullcharge_cap=$($megacli_bin -AdpBbuCmd -aAll|grep ".*Full Charge"|awk -F : '{ print $2 }'|tr -d ' '|sort|uniq)
	bbu_fc=${bbu_fullcharge_cap%mAh}
	bbu_fc_per_dc=$(echo "scale=2;$bbu_fc / $bbu_dc * 100"|bc)
	bbu_fcdc=${bbu_fc_per_dc%.*}
	check_bbu=1
fi

if [[ $raid_degraded -ne 0 || $raid_offline -ne 0 || $raid_critical -ne 0 || $raid_failed -ne 0 || $check_bbu -eq 1 && ("$bbu_status" != "Operational" && "$bbu_status" != "Optimal" || $bbu_rc -le 50 || $bbu_fcdc -le 50) ]]; then
#	echo -n $raid_details

	IFS_SAVE=IFS
	IFS=$'\n'
	for raid_detail in $raid_details; do
		echo -n "$raid_detail<br>"
	done
	IFS=$IFS_SAVE

	if [ $check_bbu -eq 1 ]; then
		bbu_info
	fi
	exit 2

else
	echo -n "Megaraid OK <br>"
	if [ $check_bbu -eq 1 ]; then
		bbu_info
	fi
	exit 0
fi

}


adaptec() {

if [ ! -f $arcconf_bin ]; then
        echo "No arcconf binary file found!"
        exit 3
fi

raid_details=$($arcconf_bin GETCONFIG 1 AD)
raid_status=$(echo "$raid_details"|grep "Controller Status"|awk -F : '{print $2}'|tr -d '')
logical_DFD=$(echo "$raid_details"|grep "Logical devices/Failed/Degraded"|awk -F : '{print $2}'|tr -d '')
raid_failed=$(echo "$logical_DFD"|awk -F / '{print $2}')
raid_degraded=$(echo "$logical_DFD"|awk -F / '{print $3}')

if [[ "$raid_status" == "Optimal" || $raid_failed -eq 0 || $raid_degraded -eq 0 ]]; then
	echo "Adaptec raid Ok"
	exit 0
else
	echo -n "Adaptec raid status: $raid_status<br>"
	echo -n "Logical devices/Failed/Degraded: $logical_DFD"
	exit 2
fi

}

######### MAIN #########

if [ $# -ne 1 ]; then
        help
fi

if [ "$1" == "softraid" ]; then
        softraid
elif [ "$1" == "adaptec" ]; then
	adaptec
elif [ "$1" == "megaraid" ]; then
	megaraid
elif [ "$1" == "megaraid+bbu" ]; then
	megaraid bbu
else
	help
fi

