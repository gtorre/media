#! /bin/sh
#
# Plexmediaserver: Stops/Starts/Restarts and statuses Plex Media Server
# chkconfig:   235 20 80
# Description: Starts the Plex Media Server
#
### BEGIN INIT INFO
# Provides: Plex Media Server
# Required-Start: $network
# Should-Start: Plex Media Server
# Required-Stop:
# Default-Start: 3 5
# Default-Stop: 0 1 2 6
# Short-Description: Plex Media Server
# Description: PlexInc developed super duper media server. Totally awsome!
### END INIT INFO
#
#
# Added 1 second delay to prevent startup failure on systemd systems using ssd
#
sleep 1

[ $UID -eq 0 ] || exit 4

PMS_BIN="Plex Media Server"

# Source function library
if [ -f /etc/rc.status ]; then
   . /etc/rc.status
   rc_reset
elif [ -f /etc/rc.d/init.d/functions ]; then
   . /etc/rc.d/init.d/functions
fi

# Source Plex Variables
[ -r /etc/sysconfig/PlexMediaServer ] && . /etc/sysconfig/PlexMediaServer

RETVAL=0
PROG="PlexMediaServer"
CONFIG="/etc/sysconfig/$PROG"

# Source config

. $CONFIG

# Set lockfile differently if on SuSE

if [ -f /etc/SuSE-release ]; then
  LOCKFILE="/var/lock/$PROG"
else
  LOCKFILE="/var/lock/subsys/$PROG"
  PIDFILE="/var/run/$PROG.pid"
fi

start()
{
        test -x "$PLEX_MEDIA_SERVER_HOME/$PMS_BIN" || { echo "$PLEX_MEDIA_SERVER_HOME/$PMS_BIN not installed"; if [ "$1" = "stop" ]; then exit 0; else exit 5; fi; }
        [ -f "$CONFIG" ] || exit 6
        if [ ! -f "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR" ];
        then
         su -s /bin/sh $PLEX_USER -c 'mkdir -p "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR" > /dev/null 2>&1'
         if [ ! $? -eq 0 ]; then
          echo "WARNING COULDN'T CREATE $PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR, MAKE SURE I HAVE PERMISSON TO DO THAT!"
          exit 1
         fi
        fi
        if [ -f /etc/SuSE-release ] ; then
           echo -n "Starting Plex Media Server: "
           export HOME=$PLEX_MEDIA_SERVER_HOME
           startproc -u $PLEX_USER "$PLEX_MEDIA_SERVER_HOME/$PMS_BIN"
           rc_status -v
        else
           echo -n $"Starting $PROG: "
           su -s /bin/sh $PLEX_USER -c ". $CONFIG; cd $PLEX_MEDIA_SERVER_HOME; ./'$PMS_BIN' > /dev/null 2>&1" &
           sleep 3
           eval "$@" && success || failure
           touch $LOCKFILE
           RETVAL=$?
           echo
           [ $RETVAL = 0 ] && ln -s "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/plexmediaserver.pid" $PIDFILE
           return $RETVAL
       fi
}

stop()
{
        if [ -f /etc/SuSE-release ] ; then
           echo -n "Stopping Plex Media Server: "
           killproc -SIGQUIT "$PLEX_MEDIA_SERVER_HOME/$PMS_BIN"
           rc_status -v
        else
           [ -f "$PIDFILE" ] || exit 0
           PID=`cat $PIDFILE`
           echo -n $"Stopping $PROG: "
           kill -3 "`cat $PIDFILE`"&& success || failure
           if [ -f $PIDFILE ]; then
             PLEX=1
             while [ $PLEX -eq 1 ]; do
             sleep 3
             echo
               if [ `ps -ef|grep $PID|grep -v grep|wc -l` -eq 1 ]; then
                PLEX=1
                echo -n $"Waiting for Plex to Stop: "
                else
                PLEX=0
               fi
             done
             echo -n $"Stopped $PROG" && success || failure
           fi
           RETVAL=$?
           echo
           rm -f $PIDFILE
           rm -f $LOCKFILE
           return $RETVAL
        fi
}

check_status ()
{
#        echo -n "Checking for service Plex Media Server: "
        if [ -f /etc/SuSE-release ]; then
           /sbin/checkproc "$PLEX_MEDIA_SERVER_HOME/$PMS_BIN"
           rc_status -v
        else
           status $PROG
           RETVAL=$?
        fi
}

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		stop
                sleep 1
		start
		;;
	status)
		check_status
		;;
	*)
		echo $"Usage: $0 {start|stop|restart|status}"
		RETVAL=2
		[ "$1" = 'usage' ] && RETVAL=0
esac

exit $RETVAL
