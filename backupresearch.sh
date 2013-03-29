#!/bin/bash 
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

cd ~/research
git commit -a -m "autoupdate `date +%F-%T`"
git push backup master
