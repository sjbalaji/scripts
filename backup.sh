#!/bin/bash
rsync --rsh='sshpass -p balaji321 ssh -l balaji' -avz --progress ~/research  10.6.9.52:/balajiHomeBackup
