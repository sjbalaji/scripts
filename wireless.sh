#!/bin/sh

iwconfig wlan2 2>&1 | grep -q no\ wireless\ extensions\. && {
  echo wired
  exit 0
}

essid=`iwconfig wlan2 | awk -F '"' '/ESSID/ {print $2}'`
stngth=`iwconfig wlan2 | awk -F '=' '/Quality/ {print $2}' | cut -d '/' -f 1`
bars=`expr $stngth / 7`
case $bars in
  0)  bar="[$(tput setaf 1)$(tput bold)----------$(tput sgr0)]" ;;
  1)  bar="[$(tput setaf 2)$(tput bold)*$(tput setaf 1)$(tput bold)---------$(tput sgr0)]" ;;
  2)  bar="[$(tput setaf 2)$(tput bold)**$(tput setaf 1)$(tput bold)--------$(tput sgr0)]" ;;
  3)  bar="[$(tput setaf 2)$(tput bold)***$(tput setaf 1)$(tput bold)-------$(tput sgr0)]" ;;
  4)  bar="[$(tput setaf 2)$(tput bold)****$(tput setaf 1)$(tput bold)------$(tput sgr0)]" ;;
  5)  bar="[$(tput setaf 2)$(tput bold)*****$(tput setaf 1)$(tput bold)-----$(tput sgr0)]" ;;
  6)  bar="[$(tput setaf 2)$(tput bold)******$(tput setaf 1)$(tput bold)----$(tput sgr0)]" ;;
  7)  bar="[$(tput setaf 2)$(tput bold)*******$(tput setaf 1)$(tput bold)---$(tput sgr0)]" ;;
  8)  bar="[$(tput setaf 2)$(tput bold)********$(tput setaf 1)$(tput bold)--$(tput sgr0)]" ;;
  9)  bar="[$(tput setaf 2)$(tput bold)*********$(tput setaf 1)$(tput bold)-$(tput sgr0)]" ;;
  10) bar="[$(tput setaf 2)$(tput bold)**********$(tput sgr0)]" ;;
  *)  bar="[$(tput setaf 1)$(tput bold)----!!----$(tput sgr0)]" ;;
esac
echo -e "$(tput setaf 1)$(tput bold)${essid}$(tput sgr0): ${bar}"
exit 0