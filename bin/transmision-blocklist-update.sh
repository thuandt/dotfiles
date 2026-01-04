#!/bin/sh
# Filename: transmission-blocklist-update.sh
# Description : Update blocklists for transmission-daemon
# Last Modified: Thu 29 Nov 2012 09:36:44 PM ICT

BLOCKLIST_FILE="$HOME/.config/transmission-daemon/blocklists/blocklist"

if wget http://bit.ly/Abdwj4 -O /tmp/spyware.gz 1>/dev/null 2>&1 ; then
    if wget http://bit.ly/zFsvx1 -O /tmp/badpeers.gz 1>/dev/null 2>&1 ; then
        cd /tmp
        gunzip spyware.gz badpeers.gz
        rm -f ${BLOCKLIST_FILE} && cat spyware badpeers > ${BLOCKLIST_FILE}
        /etc/init.d/transmission-daemon stop
        sleep 5
        /etc/init.d/transmission-daemon start
    fi
    echo "blocklist updated"
else
    echo "blocklist not updated"
fi

