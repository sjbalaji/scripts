#!/bin/bash
#13/10/2011
#script to automatically restart cntlm :P
while [ 1 -lt 2 ]
do 
sleep 5
a=`ps aux | grep  cntlm | grep root`
if [ -n "$a" ]; then
#This means that the cntlm is running so do nothing
a=`ps aux | grep cntlm  | grep root`
#echo non null a=$a
else
#WTF who killed cntlm restart the cntlm  
a=`ps aux | grep cntlm  | grep root`
#echo null a=$a
sudo cntlm
fi 
done