#!/bin/bash
# by Paul Colby (http://colby.id.au), no rights reserved ;)

# Modified by balaji setty iit madras (sjbalaji@cse.iitm.ac.in) no rights reserved :P
# For CPU utilization 
MY_IP=`ifconfig | grep 10.6.9 | awk '{ print $2}' | cut -d ':' -f2`
echo " Stats for machine : $MY_IP"
PREV_TOTAL=0
PREV_IDLE=0
######################################################
# This section is modified by balaji 
# For Network statistics
# All the data collected from the proc is in bytes 
# The out and in will give the transfer in bytes  speed per second 
DATA_OUT_OLD=0
#DATA_OUT_NEW=`cat /proc/net/dev | grep em1 | cut -d ' ' -f37`
DATA_OUT_NEW=`cat /proc/net/dev | grep em1 | awk '{print $10}'`
DATA_IN_OLD=0
#DATA_IN_NEW=`cat /proc/net/dev | grep em1 | cut -d ' ' -f5`
DATA_IN_NEW=`cat /proc/net/dev | grep em1 | awk '{print $2}'`
# For memory statistics 
# Note all the data collected from proc regarding the memory information is in kB
MemUsed=`free -k | grep buffers/ | awk '{ print $3}'`
MemFree=`free -k | grep buffers/ | awk '{print $4}'`
MemTotal=`echo "$MemUsed+$MemFree" | bc`
#SwapTotal=`cat /proc/meminfo | grep SwapTotal | cut -d ' ' -f8`
#SwapFree=`cat /proc/meminfo | grep SwapFree | cut -d ' ' -f9`
SwapTotal=`cat /proc/meminfo | grep SwapTotal | awk '{print $2}'`
SwapFree=`cat /proc/meminfo | grep SwapFree | awk '{print $2}'`
SwapUsed=`echo "$SwapTotal-$SwapFree" | bc`
######################################################
while true; do
  CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
  unset CPU[0]                          # Discard the "cpu" prefix.
  IDLE=${CPU[4]}                        # Get the idle CPU time.

  # Calculate the total CPU time.
  TOTAL=0
  for VALUE in "${CPU[@]}"; do
    let "TOTAL=$TOTAL+$VALUE"
  done
######################################################
# This section is modified by balaji 
  DATA_IN_OLD=$DATA_IN_NEW
  DATA_IN_NEW=`cat /proc/net/dev | grep em1 | awk '{print $2}'`
  DATA_OUT_OLD=$DATA_OUT_NEW
  DATA_OUT_NEW=`cat /proc/net/dev | grep em1 | awk '{print $10}'`
  # Calculate the CPU usage since we last checked.
  let "DIFF_IDLE=$IDLE-$PREV_IDLE"
  let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
  let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
  let "OUT_DATA_PS=($DATA_OUT_NEW-$DATA_OUT_OLD)*1000/(1024*1024)"
  let "IN_DATA_PS=($DATA_IN_NEW-$DATA_IN_OLD)*1000/(1024*1024)"
  echo "CPU:$DIFF_USAGE out:$OUT_DATA_PS in:$IN_DATA_PS MemTotal:$MemTotal MemFree:$MemFree MemUsed:$MemUsed SwapTotal:$SwapTotal SwapFree:$SwapFree SwapUsed:$SwapUsed"
######################################################  
  # Remember the total and idle CPU times for the next check.
  PREV_TOTAL="$TOTAL"
  PREV_IDLE="$IDLE"
  # Wait before checking again.
  sleep 1
done