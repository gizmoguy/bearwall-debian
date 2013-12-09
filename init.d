#! /bin/sh
### BEGIN INIT INFO
# Provides:          bearwall
# Required-Start:    $remote_fs $syslog $network
# Required-Stop:     $remote_fs $syslog $network
# Default-Start:     S
# Default-Stop:      1
# Short-Description: Bearwall Firewall
# Description:       This script starts a firewall generated by the
#                    Bearwall (aka Perry's Firewall Script).   
### END INIT INFO
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
NAME=bearwall
DAEMON=/usr/sbin/${NAME}
IPAC=/usr/sbin/fetchipac
DESC="Bearwall (aka Perry's Firewall Script)"

test -x $DAEMON || exit 0

set -e

case "$1" in
  start|restart|force-reload)
	echo -n "Starting $DESC: $NAME"
	$DAEMON > /dev/null
	if [ -x $IPAC ]; then
	    $IPAC -S
	fi
	echo "."
	;;
  stop)
    $DAEMON -f
	;;
  panic)
	echo -n "Flushing ipv4 firewall:"
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
	echo -n "Flushing ipv6 firewall:"
	cat /proc/net/ip6_tables_names | while read table; do
		echo -n " $table"
		/sbin/ip6tables -t $table --flush
		/sbin/ip6tables -t $table --delete-chain
		# Set everything to deny
		/sbin/ip6tables -t $table -nL | grep ^Chain | awk '{print $2}' |
			while read chain; do
				/sbin/ip6tables -t $table --policy $chain DENY
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
