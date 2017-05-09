#!/bin/bash

OK=0
WARNING=1
CRITICAL=2

function usage { 
	echo "Usage: $0 -c -w -C -W -x" 
    	exit 3
}

function param_check {
	echo "Warning value biger than critical!"
	exit 3

}
exclude_dirs=''

while getopts ":c:w:C:W:x:" o; do
    case "${o}" in
        w)
            warn=${OPTARG}
            ;;
        c)
            crit=${OPTARG}
            ;;
        W)
            iwarn=${OPTARG}
            ;;
        C)
            icrit=${OPTARG}
            ;;
        x)
            exclude_dirs=$exclude_dirs${OPTARG}" "
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${warn}" ] || [ -z "${crit}" ] || [ -z "${iwarn}" ] || [ -z "${icrit}" ]; then
    usage
fi

if [ $warn -gt $crit ] || [ $iwarn -gt $icrit ]; then
	param_check
fi

if [ "${exclude_dirs}" != '' ]; then
	excl=""
	for i in $exclude_dirs; do
	    excl=$excl$i"|"
	done
	excl=${excl%*|}
	df=( $(df -Ph|grep -v "Filesystem"|egrep -v "$excl"|awk '{ print $6" "$2" "$4" "$5}') )
	df_inode=( $(df -iPh|grep -v "Filesystem"|egrep -v "$excl"|awk '{ print $6" "$2" "$4" "$5}') )
else
	df=( $(df -Ph|grep -v "Filesystem"|awk '{ print $6" "$2" "$4" "$5}') )
	df_inode=( $(df -iPh|grep -v "Filesystem"|awk '{ print $6" "$2" "$4" "$5}') )

fi

status_warn=0
status_crit=0
msg_ok=""
msg_warn=""
msg_crit=""
let "max =  ${#df[@]} - 1"
for pos in $(seq 0 4 $max); do
	let "i=pos+3"
	used=${df[@]:$i:1}
	used=${used%*%}
	iused=${df_inode[@]:$i:1}
	iused=${iused%*%}

	let "pp1=$pos+1"
	let "pp2=$pos+2"
	let "pp3=$pos+3"

	msg="${df[@]:$pos:1} ${df[@]:$pp1:1}/${df[@]:$pp2:1}"
	imsg="inode usage ${df_inode[@]:$pp3:1} on  ${df_inode[@]:$pos:1}"
	if [ $used -gt $crit ]; then
		msg_crit=$msg_crit$msg"   "
		status_crit=1
	elif  [ $iused -gt $icrit ]; then
                msg_crit=$msg_crit$imsg"   "
                status_crit=1
	elif [ $used -gt $warn ] && [ $used -le $crit ]; then
		msg_warn=$msg_warn$msg"   "
		status_warn=1
        elif [ $iused -gt $iwarn ] && [ $iused -le $icrit ]; then
		msg_warn=$msg_warn$imsg"   "
		status_warn=1
	else
		msg_ok=$msg_ok$msg"   "
	fi
done

if [ $status_crit -eq 1 ]; then
	echo "$msg_crit"
	exit $CRITICAL
elif [ $status_warn -eq 1 ]; then
	echo "$msg_warn"
	exit $WARNING
else
	echo "$msg_ok"
	exit $OK
fi
