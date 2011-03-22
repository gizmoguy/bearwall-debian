#! /bin/bash
### BEGIN INIT INFO
# Provides:          firewall
# Required-Start:    $remote_fs $syslog $network
# Required-Stop:     $remote_fs $syslog $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Isomers Firewall
# Description:       This script starts a firewall generated by Isomers
#                    Firewall Script.
### END INIT INFO
# firewall	This script generates a firewall based on Isomers Firewall
#		Script
#
#		Written by Miquel van Smoorenburg <miquels@cistron.nl>.
#		Modified for Debian GNU/Linux
#		by Ian Murdock <imurdock@gnu.ai.mit.edu>.
#		Modified to work with firewall by 
#		Perry <firewall@isomer.meta.net.nz>
#
# Version:	@(#)skeleton  1.9.1  08-Apr-2002  miquels@cistron.nl
#

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/sbin/firewall
IPAC=/usr/sbin/fetchipac
NAME=firewall
DESC="firewall"

test -x $DAEMON || exit 0

set -e

case "$1" in
  start|restart|force-reload)
	echo -n "Starting $DESC: $NAME"
	$DAEMON &>/dev/null
	if [ -x $IPAC ]; then
	    $IPAC -S
	fi
	echo "."
	;;
  stop)
	echo -n "Flushing firewall:"
  	cat /proc/net/ip_tables_names | while read table; do
		echo -n " $table"
		/sbin/iptables -t $table --flush
		/sbin/iptables -t $table --delete-chain
		# Set everything to accept
		/sbin/iptables -t $table -nL | grep ^Chain | awk '{print $2}' |
			while read chain; do
				/sbin/iptables -t $table --policy $chain ACCEPT
			done
	done
	echo "."
	;;
  panic)
	echo -n "Flushing firewall:"
  	cat /proc/net/ip_tables_names | while read table; do
		echo -n " $table"
		/sbin/iptables -t $table --flush
		/sbin/iptables -t $table --delete-chain
		# Set everything to deny
		/sbin/iptables -t $table -nL | grep ^Chain | awk '{print $2}' |
			while read chain; do
				/sbin/iptables -t $table --policy $chain DENY
			done
	done
	echo "."
	;;
  *)
	N=/etc/init.d/$NAME
	# echo "Usage: $N {start|stop|restart|reload|force-reload}" >&2
	echo "Usage: $N {start|stop|restart|force-reload}" >&2
	exit 1
	;;
esac

exit 0
