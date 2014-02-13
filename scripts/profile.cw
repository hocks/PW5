# @(#)27	1.20  src/bos/etc/profile/profile, cmdsh, bos520 8/9/94 12:01:38
# IBM_PROLOG_BEGIN_TAG 
# This is an automatically generated prolog. 
#  
# bos520 src/bos/etc/profile/profile 1.20 
#  
# Licensed Materials - Property of IBM 
#  
# (C) COPYRIGHT International Business Machines Corp. 1989,1994 
# All Rights Reserved 
#  
# US Government Users Restricted Rights - Use, duplication or 
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp. 
#  
# IBM_PROLOG_END_TAG 
#
# COMPONENT_NAME: (CMDSH) Shell related commands 
#
# FUNCTIONS:
#
# ORIGINS: 3, 26, 27
#
# (C) COPYRIGHT International Business Machines Corp. 1989, 1994
# All Rights Reserved
# Licensed Materials - Property of IBM
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
################################################################

# System wide profile.  All variables set here may be overridden by
# a user's personal .profile file in their $HOME directory.  However,
# all commands here will be executed at login regardless.

trap "" 1 2 3
readonly LOGNAME

# DisAllow general users to login 
/etc/cw_restrict_login
if [ $? != 0 ]
then
        kill -9 $$ $PPID
fi

# Automatic logout, include in export line if uncommented
# TMOUT=120

# The MAILMSG will be printed by the shell every MAILCHECK seconds
# (default 600) if there is mail in the MAIL system mailbox.
MAIL=/usr/spool/mail/$LOGNAME
MAILMSG="[YOU HAVE NEW MAIL]"

# If termdef command returns terminal type (i.e. a non NULL value),
# set TERM to the returned value, else set TERM to default lft.
TERM_DEFAULT=lft
TERM=`termdef`
TERM=${TERM:-$TERM_DEFAULT}

# If LC_MESSAGES is set to "C@lft" and TERM is not set to "lft",
# unset LC_MESSAGES. 
if [ "$LC_MESSAGES" = "C@lft" -a "$TERM" != "lft" ]
then
	unset LC_MESSAGES
fi

export LOGNAME MAIL MAILMSG TERM

trap 1 2 3
