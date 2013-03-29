#!/bin/bash

SLAVES_PATH="/home/balaji/scripts/forSriram/slaves.txt"

if [ ! -f $SLAVES_PATH ]; then 
    echo "$SLAVES_PATH : does not exists"
    exit 1
elif [ ! -r $SLAVES_PATH ]; then 
    echo "$SLAVES_PATH : cannot be read "
    exit 2
fi

for i in $(cat $SLAVES_PATH)
do
    echo "$i"
    command="sshpass -p hadoop123 ssh hadoopnew@"
    completecommand=$command$i" 'date'"
    $completecommand
done