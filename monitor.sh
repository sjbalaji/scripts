################################################################################
#!/bin/bash                                                                    #
################################################################################
# A primitive cpu temperature monitoting script                                #
# This is to test the behaviour of the cpu temperature based on the            #
# system load                                                                  #
################################################################################
# S J Balaji                                                                   #
# CS10S020                                                                     #
# IIT Madras                                                                   #
################################################################################
while [ 1 -lt 2 ]
do
Core1=`sensors  | grep Core\ 0: | cut -d + -f2 | cut -d . -f1`
Core2=`sensors  | grep Core\ 2: | cut -d + -f2 | cut -d . -f1`
echo $Core1 $Core2 >> temp.txt 
echo $Core1 $Core2 
sleep 1
done;
################################################################################