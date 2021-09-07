#!/bin/sh
export ipstatus=$(cat /etc/network/interfaces | grep static | awk '{print $2; exit}')
#export ipcontroller=$(ifconfig $ipstatus | awk '/inet / {print $2; exit}')
export ipcontroller=$(cat /etc/hostname | grep compute | awk '{print $1}')
export iphosts=$(cat /etc/hosts | grep $ipcontroller | awk '{print $1}')
export ethManual=$(cat /etc/network/interfaces | grep manual | awk '{print $2; exit}')
