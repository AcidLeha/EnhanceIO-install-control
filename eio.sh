#!/bin/bash

EIOMOD=/lib/modules/`uname -r`/extra/enhanceio/enhanceio.ko
MODULE="enhanceio"
MODFILE="/etc/modules"
TMODFILE="/etc/modules.temp"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

case "$1" in
        install)
	    apt-get update -y
	    apt-get install git build-essential -y
	    mkdir -p ~/opt/build/eio
	    cd ~/opt/build/eio
	    git clone https://github.com/stec-inc/EnhanceIO.git
	    cd ~/opt/build/eio/EnhanceIO/Driver/enhanceio
	    make clean
	    make && make install
   	    cp ~/opt/build/eio/EnhanceIO/CLI/eio_cli /sbin/
   	    chmod 700 ~/opt/build/eio/EnhanceIO/CLI/eio_cli
	    awk '!/enhanceio/' $MODFILE > $TMODFILE && cp $TMODFILE $MODFILE # removing old possible records 
	    echo -e "enhanceio_fifo\nenhanceio_lru\nenhanceio" >> $MODFILE
            modprobe enhanceio_fifo
            modprobe enhanceio_lru
            modprobe enhanceio

            ;;
        start)
	if [[ -f $EIOMOD ]]
        then
	modprobe enhanceio_fifo
	modprobe enhanceio_lru
        modprobe enhanceio
	echo "EnhanceIO started"
	else
        echo "enhanceio is not installed"
	fi
            ;;         
        stop)
	    rmmod enhanceio_lru
	    rmmod enhanceio_fifo
	    rmmod enhanceio
	    echo "EnhanceIO stopped"
            ;;
	uninstall)
            rmmod enhanceio_lru
            rmmod enhanceio_fifo
            rmmod enhanceio
	    rm /sbin/eio_cli
	    awk '!/enhanceio/' $MODFILE > $TMODFILE && cp $TMODFILE $MODFILE
	    echo "EnhanceIO uninstalled"
	;;
        status)
	if [[ `lsmod | grep -o ^$MODULE` ]]
	then
	echo "enhanceio is up"
	else
	echo "enhanceio is down"
	fi
	if [[ ! -f $EIOMOD ]]; then echo "enhanceio not installed"; fi
        if [[ `cat $MODFILE | grep -o ^$MODULE` ]]; then echo "enhanceio autoloading"; fi
            ;;
         
        *)
            echo $"Usage: $0 {start|stop|install|uninstall|status}"
            exit 1
 
esac


