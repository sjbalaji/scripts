#!/bin/bash
gcc cpu.c -o load
./load &
sleep 4
pidof load | xargs kill -9 
sleep 3
./load &
sleep 1
pidof load | xargs kill -9 
./load &
sleep 4
pidof load | xargs kill -9 
sleep 3
./load &
sleep 1
pidof load | xargs kill -9 
./load &
sleep 4
pidof load | xargs kill -9 
sleep 3
./load &
sleep 1
pidof load | xargs kill -9 