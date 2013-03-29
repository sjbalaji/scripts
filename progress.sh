#!/bin/bash
#
# the original dget.sh script:
# (c) 2007 by Robert Manea
#
# bashtardized and heavily modded for uzbl:
# 2009 by pbrisbin
#
# requires:
#   dzen2
#   gdbar
#   wget
#   xwininfo
#   wmctrl (for now)
#
###
 
# dzen
# xft font available with dzen2-svn from aur
#FONT='-xos4-terminus-*-*-*-*-12-*-*-*-*-*-*-*'
FONT='Verdana-8'
FG='#606060'
BG='#303030'
 
# gdbar
bar_FG='#909090'
bar_BG='#606060'
bar_H=7
bar_W=150
 
# the place to download to
DIR="$HOME/Downloads"
 
# refresh rate on the progress bar
SECS=1
 
# this allows for some simple WM-specific adjustments
pad_Y=30
pad_X=2
 
# these are passed in from uzbl
PID="$2"
XID="$3"
URL="$8"
 
# auto open the file post-download based on the
# file's extension
# TODO: please people, add your own here and report them on
# the uzbl wiki page.  these are the ones i use, i'd love
# to have a more complete list
open() {
  case "$1" in
    *.pdf)                                      epdfview "$1" &      ;;
    *.jpg|*.png|*.jpeg)                         mirage "$1" &        ;;
    *.txt|*README*|*.pl|*.sh|*.py|*.hs)         urxvtc -e vim "$1" & ;;
    *.mov|*.avi|*.mpeg|*.mpg|*.flv|*.wmv|*.mp4) mplayer "$1" &       ;;
  esac
}
 
# this function returns XY geometry for the spawning uzbl
find_uzbl() {
  # x-winid is in the documentation but coming over blank for me
  # if it's blank, wmctrl provides a workaround
  [ "$XID" = "" ] && XID="$(wmctrl -lp | awk "/$PID/"'{print $1}')"
 
  # someone better with awk could probably parse this all at once
  uzbl_X=$(xwininfo -id "$XID" | awk '/Corners/ {print $2}' | cut -d '+' -f 2)
  uzbl_Y=$(xwininfo -id "$XID" | awk '/Corners/ {print $2}' | cut -d '+' -f 3)
  uzbl_W=$(xwininfo -id "$XID" | awk '/Width/   {print $2}')
  uzbl_H=$(xwininfo -id "$XID" | awk '/Height/  {print $2}')
 
  # some math here to place the first progress bar just above
  # the uzbl status bar
  H=16
  W=$uzbl_W
  X=$((uzbl_X+pad_X))
  Y=$((uzbl_Y+uzbl_H-pad_Y))
}
 
# file to dump wget progress into and read from
# it needs to be specific to this DL instance
STAT="/tmp/dl_progress.$$"
 
# this file holds the HW and XY to use for the next
# download instance and must span across each download
LOC="/tmp/dl_location"
 
# if no other wgets are running, we clear the stored
# location.  this is the best way i can determine if
# this is a new 'downloading session' and we need to
# start over at the bottom of the stack
ps -A | grep -q wget || rm -f $LOC
 
# and if the location file still exists we source it
# to know where to place the next status bar, else
# we find uzbl
[ -f $LOC ] && . $LOC || find_uzbl
 
# set up the location of the next display
new_Y=$((Y-H))
echo -e "H=$H\nW=$W\nX=$X\nY=$new_Y\n" > $LOC
 
# get filename from the url and convert some hex codes
# i hate spaces in filenames so i'm switching them
# with underscores here, adjust the first s///g if
# you want to keep the spaces
FILE="$(basename $URL | sed -r \
's/[_%]20/\_/g;s/[_%]22/\"/g;s/[_%]23/\#/g;s/[_%]24/\$/g;
s/[_%]25/\%/g;s/[_%]26/\&/g;s/[_%]28/\(/g;s/[_%]29/\)/g;
s/[_%]2C/\,/g;s/[_%]2D/\-/g;s/[_%]2E/\./g;s/[_%]2F/\//g;
s/[_%]3C/\</g;s/[_%]3D/\=/g;s/[_%]3E/\>/g;s/[_%]3F/\?/g;
s/[_%]40/\@/g;s/[_%]5B/\[/g;s/[_%]5C/\\/g;s/[_%]5D/\]/g;
s/[_%]5E/\^/g;s/[_%]5F/\_/g;s/[_%]60/\`/g;s/[_%]7B/\{/g;
s/[_%]7C/\|/g;s/[_%]7D/\}/g;s/[_%]7E/\~/g;s/[_%]2B/\+/g')"
 
# download
wget -O "$DIR/$FILE" --user-agent=Firefox "$URL" > $STAT 2>&1 &
pid=$!
 
# show the dzen notification
(while ps -A | grep -q $pid; do
  REM="$(awk '/s$/ {print $NF}' $STAT | tail -n1)"
  PROG=$(grep -Eo  " [0-9]{1,3}%" $STAT | tail -n1 | sed 's/%$//g')
  echo -n "  Downloading ${FILE:0:22}... (${REM:-unknown})  "
  echo "${PROG:-0} 100" | gdbar -h $bar_H -w $bar_W -fg $bar_FG -bg $bar_BG
  sleep "$SECS"
done; echo "  Download saved to $DIR/$FILE"; sleep 3) | dzen2 -ta l -w $W -h $H -x $X -y $Y -fg $FG -bg $BG -fn "$FONT" -e "onstart=stick;button3=exec:kill $pid,rm -f $STAT,exit:1"
 
# finally, auto-open the downloaded file
[ $? -eq 0 ] && open "$DIR/$FILE"
 
rm -f "$STAT"
 
exit 0