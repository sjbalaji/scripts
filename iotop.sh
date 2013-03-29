#!/bin/bash
sleep 1
while [ 1 -lt 2 ];
do
#    echo loop 1
    #date
    pid=(`ls /proc | grep "[0-9]"`)
#echo number of elements ${#pid[@]}
    lim=${#pid[@]}
    for((i=1;i<=lim;i++));
    do
	if [ -z ${pid[i]} ]; then
	    pid[i]=""	
	else
	    if [ -f  /proc/${pid[i]}/io ]; then
		write_bytes[i]=`sudo cat /proc/${pid[i]}/io  | grep "write_bytes" | head -n 1 | awk '{print $2}'`
	    #echo ${write_bytes[i]}
	    #echo file exists
	    else
	    #echo $i empty basic removind pid
		write_bytes[i]=""
		pid[i]=""
	    fi
	fi
    done
    #date
    sleep 1
    lim=${#pid[@]}
#    echo loop 2
    #date
    for((i=1;i<=lim;i++));
    do
	if [ -z ${pid[i]} ]; then
	    pid[i]=""
	else
	    if [ -f  /proc/${pid[i]}/io ]; then
		write_bytes1[i]=`sudo cat /proc/${pid[i]}/io  | grep "write_bytes" | head -n 1 | awk '{print $2}'`
	    #echo ${write_bytes1[i]}
	    #echo file exists
	    else
	    #echo $i empty basic removind pid
		write_bytes1[i]=""
		pid[i]=""
	    fi
	fi
    done
    #date
#echo number of elements $lim ${#pid[@]}

    lim=${#pid[@]}
#    echo processing
    #date
total=0
    for((i=1;i<=lim;i++));
    do
	if [ "$pid[i]" != "" ] && [ "${write_bytes1[i]}" != "" ] && [ "${write_bytes[i]}" != "" ]; then
	    diff=`echo ${write_bytes1[i]} - ${write_bytes[i]} | bc`
	    delta[i]=$diff
	    total=`echo $total + $diff | bc`
	fi
    done
	for((i=1;i<=lim;i++));
	do
	    if [ "$pid[i]" != "" ] && [ "${write_bytes1[i]}" != "" ] && [ "${write_bytes[i]}" != "" ]; then
		diff=`echo ${write_bytes1[i]} - ${write_bytes[i]} | bc`
		delta[i]=$diff
		r=`echo  "scale=4; ${delta[i]} / $total " | bc`
		echo ${pid[i]} $r >> iotemp
#		echo ${pid[i]} $r 
	    fi
	done

	#date
	clear
	rm idump
	cat iotemp  |sort -k 2 -r | head -n 30 | tee idump
	rm iotemp

done