#!/bin/bash

## This script is to cancel the SDSC-epo.sh
## It won't be effective after SDSC-epo.sh start killing process
## as the machine is not going to be in a consistent state
##
## The EPO script is unstoppable if its internal delay passed
## Martin W. Margo

## Usage: 
## TG-epo-cancel.sh 
usage() {
echo "TG-epo-cancel.sh"
echo "Usage:   TG-epo-cancel.sh "
echo "		 -h : print this help"
}

HOSTNAME=`/bin/hostname`
DELAY=30

USER=`/usr/bin/whoami`
if [ $USER != "root" ] 
then
    echo "This script has to be run as root. bye!"
    exit 1
fi

if [ $# == 0 ]
then
	usage
	exit
fi

while [ $# -gt 0 ]
do
	case "$1" in
		-h) usage;exit;;
		*) usage; exit;;
	esac
	shift
done




sleep $DELAY


## Only datastar needs ps -ef, the rest of the system can give the
## process listing using ps -auxw
## so, I will see if the hostname is a DS machine, else it will do
## ps -auxwww
if [[ "$HOSTNAME" == "dscws-e" ]] ; then
    EPO_PID=`/bin/ps -ef | grep SDSC-epo.sh | grep -v grep | awk '{print $2}'`
    `kill -9 $EPO_PID`
    exit 0;
fi

EPO_PID=`/bin/ps -auxw | grep SDSC-epo.sh | grep -v grep | awk '{print $2}'`
`kill -9 $EPO_PID`
exit 0
