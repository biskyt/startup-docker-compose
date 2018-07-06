#!/bin/bash

# Verify we are running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# specify root for find as a command option
ROOT_DIR='.'
DEPTH=2

setroot=0
setdepth=0

for i in "$@"
do
case $i in
	--help) echo "USAGE: backupscript -r <ROOT_DIR> [-x <DEPTH>]
      Where:
        ROOT_DIR = the start folder in which to scan for docker-compose.yml files
        DEPTH = How many levels down from the ROOT_DIR to scan for docker-compose files

        Run script @reboot using cron
        "
		;;
    -r|--root) setroot=1
        ;;
    -x|-depth) setdepth=1
        ;;
	*)  if [ ! -z "$i" ]; then
			if [ "$setroot" = "1" ]; then
				ROOT_DIR=$i
				setroot=0
            elif [ "$setdepth" == "1" ]; then
				DEPTH=$i
                setdest=0
			else echo "Unknown command line: $i"
				exit 1
			fi
		fi
    ;;
esac
done


CUR_DIR=$PWD

# move to root dir
cd ${ROOT_DIR}

# Cleanly stop all running containers using compose
find -maxdepth ${DEPTH} -name "docker-compose.yml" -exec docker-compose -f {} up -d \;

# move back to original dir
cd ${CUR_DIR}

exit 0
