#!/bin/bash

## This script is to shutdown the cluster when a power outtage is detected
## please be careful running this script as the efect is enormous
###
## Martin W. Margo

## Usage: 
## TG-epo.sh --mode=real|test
usage() {
echo "TG-epo.sh"
echo "Usage:   TG-epo.sh "
echo "		 -r : real mode, really quick shutdown. CAUTION"
echo "		 -t : just testing, don't shutdown"
echo "		 -h : print this help"
}

EPO_MSG="TG-epo.sh is in action! Machine is shutting down at `date`"
HOSTNAME=`/bin/hostname`
MODE=""
echo $HOSTNAME
#echo $EPO_MSG
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
		-r) 
			if [[ "$MODE"  != "" ]] ; then
				#The mode has been set before, conflict
				echo "Can not specify -r and -t simulatenously"
				usage
				exit
			else
				MODE="real"
			fi;;		
		-t) 
			if [[ "$MODE" != "" ]] ; then
				echo "Can not specify -r and -t simultaneously"
				usage
				exit
			else
				MODE="test"
			fi;;
		-h) usage;exit;;
		*) usage; exit;;
	esac
	shift
done



## Before continuing, let's check if SDSC-epo-confirm.sh is running
# If it is then proceed, else it might be a false alarm
#CONFIRM_PROC=`ps -ef  | grep SDSC-epo-confirm.sh |  grep -v grep`
#if [[ $CONFIRM_PROC == ""  ]] ; then
#	echo "Shutdown cancelled. I can't find SDSC-epo-confirm.sh process"	
#	exit 1
#fi	


sleep $DELAY

if [[ "$HOSTNAME" == "tg-master" ]] ; then
	if [[ "$MODE" == "real" ]] ; then
		/opt/xcat/bin/psh compute,login,test "/sbin/halt" &
		/bin/sleep 200
		echo $EPO_MSG | /usr/bin/wall
		/sbin/halt
		echo "in the real life, the machine is dead now"	
	else
		echo "I will shutdown $HOSTNAME now"
	fi
elif [[ "$HOSTNAME" == "dtf-mgmt1" ]] ; then
	if [[ "$MODE" == "real" ]] ; then
		ps -auxwww | grep pbs | grep -v grep | awk '{print $2}' | xargs kill -9 
		/sbin/halt
	else
		echo "I will shutdown $HOSTNAME now"
	fi	
elif [[ "$HOSTNAME" == "dtf-mgmt2"  || "$HOSTNAME" == "dtf-mgmt3" ]] ; then
	if [[ "$MODE" == "real" ]] ; then
		echo $EPO_MSG | /usr/bin/wall
		/sbin/halt
		echo "in the real life, the machine is dead now"
	else
		echo "I will shutdown $HOSTNAME now"	
	fi
elif [[ "$HOSTNAME" == "dscws-e" ]] ; then
	if [[ "$MODE" == "real" ]] ; then
		echo $EPO_MSG | /usr/bin/wall
		##
		## This is a  placeholder for DS shutdown script

		## Clean up my own NFS mounts, so I don't get hung	
		/usr/sbin/umount -a -t nfs3	
		

		## try to shutdown all online p655
		export DSH_LIST=/usrtools/wcoll.655
		dsh -v -f 512 "/usr/lpp/mmfs/bin/mmshutdown"
		dsh -v -f 512 "/usr/sdsc/bin/orphan /usr/sbin/shutdown -F"
	
		## Maybe we should care about ds003 and HPSS nodes
		## but not for the first release

		## These commands are to shutdown ds002
		## shutdown GPFS in parallel with
		## 	kill users
		##	unexport NFS
		## 	unmount critical NFS partition
		## 	shutdown cleanly

		rsh ds002 "/usr/lpp/mmfs/bin/mmshutdown" &
		rsh ds002 "/root/bin/SDSC-epo-kill.sh" 
		rsh ds002 "/usr/sbin/exportfs -au"
		rsh ds002 "/usr/sbin/umount /users*"
		rsh ds002 "/usr/sbin/umount /usr/local"
		rsh ds002 "/usr/sbin/umount /work"
		rsh ds002 "/usr/sbin/umount /acct"
                rsh ds002 "/usr/sbin/umount /catalina"
                rsh ds002 "/usr/sbin/umount /sdsc"	
		rsh ds002 "/usr/sdsc/bin/orphan /usr/sbin/shutdown -F"

		## once this is completed, I can shutdown myself
		/usr/sdsc/bin/orphan /usr/sbin/shutdown -F

			
		echo "in real life, the machine is dead now"
	else
		echo "I will shutdown $HOSTNAME now"
	fi
elif [[ "$HOSTNAME" == "bgsn" ]] ; then
	if [[ "$MODE" == "real" ]] ; then
		## echo $EPO_MSG | /usr/bin/wall
		##
		## 
		ssh bg-login1 "/sbin/halt" &
		ssh bg-login2 "/sbin/halt" &
		ssh bg-login3 "/sbin/halt" &
		ssh bg-login4 "/sbin/halt" &
		
		/sbin/halt
			
		echo "in real life, the machine is dead now"
	else
		echo "I will shutdown $HOSTNAME now"
	fi
fi
