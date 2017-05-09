#!/bin/bash

usage() {
cat << EOF
usage: $0 options

This script runs a swap space activity test on the machine.

OPTIONS:
   -h Show this message
   -d Duration in seconds to monitor for swap activity (not optional)
   -w Warning Level in Kbyte/sec (not optional)
   -c Critical Level in Kbyte/sec (not optional)

Warning Level should be lower than Critical Level!

EOF
}

show_msg(){
        echo "Swap In: $swap_in_per_sec KB/s  Swap Out: $swap_out_per_sec KB/s"
}

take_lock(){
        touch /var/run/check_swap_activity.lock
}

remove_lock(){
        rm -f /var/run/check_swap_activity.lock
}

SWAP_WARN=
SWAP_CRIT=
while getopts "hd:w:c:" OPTION; do
        case "${OPTION}" in
                h)
                        usage
                        exit 3
                        ;;
                d)
                        DURATION=${OPTARG}
                        ;;
                w)
                        SWAP_WARN=${OPTARG}
                        ;;
                c)
                        SWAP_CRIT=${OPTARG}
                        ;;
                ?)
                        usage
                        exit 3
                        ;;
        esac
done

if [ -z ${DURATION} ] ||  [ -z ${SWAP_WARN} ] || [ -z ${SWAP_CRIT} ] || [ ${SWAP_WARN} -gt ${SWAP_CRIT} ] ; then
        usage
        exit 3
fi

bc="/usr/bin/bc"
#awk="/bin/awk"
awk=$(which awk)
vmstat="/usr/bin/vmstat"
if [ ! -f $awk ]; then
        echo "Awk binary not found!"
        exit 1
fi
if [ ! -f $vmstat ]; then
        echo "Vmstat binary not found!"
        exit 1
fi
if [ ! -f $bc ]; then
        echo "$bc binary not found!"
        exit 1
fi


if [ -f /var/run/check_swap_activity.lock ]; then
        echo "Check swap activity stucked, handle vmstat processes manually"
        remove_lock
        exit 1
fi

take_lock

swap_values=$($vmstat -S K 1 $DURATION|$awk '{ print $7":"$8 }'|grep '[0-9]:[0-9]')

swap_in=0
swap_out=0

for value in $swap_values
do
        in=$(echo "$value"|$awk -F : '{ print $1 }')
        out=$(echo "$value"|$awk -F : '{ print $2 }')

        let "swap_in+=in"
        let "swap_out+=out"
done

swap_in_per_sec=$(echo "$swap_in/10"|$bc)
swap_out_per_sec=$(echo "$swap_out/10"|$bc)

if [ $swap_in_per_sec -lt $SWAP_WARN ] && [ $swap_out_per_sec -lt $SWAP_WARN ]; then
        show_msg
        remove_lock
        exit 0
elif [ $swap_in_per_sec -gt $SWAP_WARN ] && [ $swap_in_per_sec -lt $SWAP_CRIT ] || ([ $swap_out_per_sec -gt $SWAP_WARN ] && [ $swap_in_per_sec -lt $SWAP_CRIT ]); then
        show_msg
        remove_lock
        exit 1
elif [ $swap_in_per_sec -gt $SWAP_CRIT ] || [ $swap_in_per_sec -lt $SWAP_CRIT ]; then
        show_msg
        remove_lock
        exit 2
fi

