 #!/usr/bin/gnuplot -persist
 # set terminal
 set terminal x11
 # plot a simple function
 plot sin(x)
 #
 # save as postscript file
 #
 set terminal postscript
 set output "test.ps"
 replot
