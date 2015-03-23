#!/bin/sh
#
### BEGIN INIT INFO
# Provides:          SABnzbd
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts SABnzbd
# Description:       starts SABnzbd
### END INIT INFO

# Source function library.
. /etc/init.d/functions

## Variables
prog=SABnzbd
lockfile=/var/lock/subsys/$prog
homedir=/apps/SABnzbd
configfile=/apps/data/.sabnzbd/sabnzbd.ini
pid=/var/run
pidfile=/var/run/sabnzbd*.pid
nice=
##

options=" --daemon --pid $pid --config-file $configfile -s 192.168.1.16"

start() {
        # Start daemon.
        echo -n $"Starting $prog: "
        daemon $nice python $homedir/SABnzbd.py $options
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && touch $lockfile
        return $RETVAL
}

stop() {
        echo -n $"Shutting down $prog: "
        killproc -p $pidfile python
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && rm -f $lockfile
        return $RETVAL
}

# See how we were called.
case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  status)
        status $prog
        ;;
  restart|force-reload)
        stop
        start
        ;;
  try-restart|condrestart)
        if status $prog > /dev/null; then
            stop
            start
        fi
        ;;
  reload)
        exit 3
        ;;
  *)
        echo $"Usage: $0 {start|stop|status|restart|try-restart|force-reload}"
        exit 2
esac
