#!/bin/bash

#Adapt this script to your needs.

DEVICES=$(find /sys/class/drm/*/status)

#inspired by /etc/acpd/lid.sh and the function it sources

displaynum=`ls /tmp/.X11-unix/* | sed s#/tmp/.X11-unix/X##`
display=":$displaynum.0"
export DISPLAY=":$displaynum.0"

# from https://wiki.archlinux.org/index.php/Acpid#Laptop_Monitor_Power_Off
export XAUTHORITY=$(ps -C Xorg -f --no-header | sed -n 's/.*-auth //; s/ -[^ ].*//; p')


#this while loop declare the $HDMI1 $VGA1 $eDP1 and others if they are plugged in
while read l
do
  dir=$(dirname $l);
  status=$(cat $l);
  dev=$(echo $dir | cut -d\- -f 2-);

  if [ $(expr match  $dev "HDMI") != "0" ]
  then
#REMOVE THE -X- part from HDMI-X-n
    dev=HDMI${dev#HDMI-?-}
  else
    dev=$(echo $dev | tr -d '-')
  fi

  if [ "connected" == "$status" ]
  then
    echo $dev "connected"
    declare $dev="yes";

  fi
done <<< "$DEVICES"


if [ ! -z "$HDMI1" -a ! -z "$DP1" ]
then
  echo "HDMI1 and DP1 are plugged in"
  xrandr --output eDP1 --auto \
         --output HDMI1 --mode 1920x1080 --right-of eDP1 --primary \
         --output DP1 --mode 1920x1080 --right-of HDMI1 --noprimary
elif [ ! -z "$HDMI1" -a -z "$DP1" ]; then
  echo "HDMI1 is plugged in, but not DP1"
  xrandr --output eDP1 --auto \
         --output HDMI1 --mode 1920x1080 --right-of eDP1 --primary \
         --output DP1 --off
elif [ -z "$HDMI1" -a ! -z "$DP1" ]; then
  echo "DP1 is plugged in, but not HDMI1"
  xrandr --output eDP1 --auto \
         --output HDMI1 --off \
         --output DP1 --mode 1920x1080 --right-of eDP1 --primary 
else
  echo "No external monitors are plugged in"
  xrandr --output eDP1 --auto --primary \
         --output HDMI1 --off \
         --output DP1 --off
fi

