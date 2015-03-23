#!/bin/sh
#
### BEGIN INIT INFO
# Provides:          SickBeard
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts SickBeard
# Description:       starts SickBeard
### END INIT INFO

# Source function library.
. /etc/init.d/functions

## Variables
prog=SickBeard
lockfile=/var/lock/subsys/$prog
homedir=/apps/SickBeard
datadir=/apps/data/.sickbeard
configfile=/apps/data/.sickbeard/sickbeard.ini
pidfile=/var/run/sickbeard.pid
nice=
##

options=" --daemon --nolaunch --pidfile=$pidfile --datadir=$datadir --config=$configfile"

start() {
        # Start daemon.
        echo -n $"Starting $prog: "
        daemon --pidfile=$pidfile $nice python $homedir/SickBeard.py $options
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
