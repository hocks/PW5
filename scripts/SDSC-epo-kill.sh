#!/bin/bash

## Helper tool to kill all un-necessary users on DS
##

kill -9 `/bin/ps -ef | \
        /bin/grep -v -e "^     UID     PID    PPID   C    STIME    TTY  TIME CMD" \
                     -e "^    root " \
                     -e "^     adm " \
                     -e "^  daemon " \
                     -e "^  imnadm " \
                     -e "^   loadl " | \
        /bin/awk '{ print $2 }'`

