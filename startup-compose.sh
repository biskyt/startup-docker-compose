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
composecmd=$(which docker-compose)

for i in "$@"; do
  case $i in
  --help)
    echo "USAGE: startup-compose.sh -r <ROOT_DIR> [-x <DEPTH>]
      Where:
        ROOT_DIR = the start folder in which to scan for docker-compose.yml files
        DEPTH = How many levels down from the ROOT_DIR to scan for docker-compose files

        Run script @reboot using cron
        "
    exit 0
    ;;
  -r | --root)
    setroot=1
    ;;
  -x | -depth)
    setdepth=1
    ;;
  *)
    if [ -n "$i" ]; then
      if [ "$setroot" = "1" ]; then
        ROOT_DIR=$i
        setroot=0
      elif [ "$setdepth" == "1" ]; then
        DEPTH=$i
        setdepth=0
      else
        echo "Unknown command line: $i"
        exit 1
      fi
    fi
    ;;
  esac
done

systemctl restart docker
sleep 5

function startup-compose-cmd() {
  echo "Starting $1"
  composecmd=$(which docker-compose)
  if [ -z $composecmd ]; then
    composecmd="$(which docker) compose"
  fi
  composecmd="${composecmd:-/usr/local/bin/docker compose}" # deal with which not returning a value
  currentdir=$(pwd)
  workingdir=$(dirname "$1")
  cd "$workingdir" || return
  $composecmd up -d
  cd "$currentdir" || exit 1
}

export -f startup-compose-cmd

# give system a chance to boot
echo "scanning $ROOT_DIR (depth $DEPTH)..."
echo "using docker-compose at $composecmd"
echo "waiting to ensure machine has time to boot..."
sleep 20

# run up on all docker-compose.yml files in tree
find "${ROOT_DIR}" -maxdepth "${DEPTH}" -name "docker-compose.yml" -exec echo up {} ... \; -exec bash -c 'startup-compose-cmd "$0"' {} \;

exit 0
