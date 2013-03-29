#!/bin/bash
for (( i = 0 ; i < 10000 ; i++ ))
do
top -n 1 | grep Cpu  | awk '{print $2}' | cut -d '%' -f1 >> mon1.txt
sleep 1
done 
