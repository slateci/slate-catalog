#!/bin/bash

# simple singularity wrapper that doesn't allow the --pid option
# Disclaimer: Based on 
#  https://wiki-dev.bash-hackers.org/scripting/posparams
#

options=()  # the buffer array for the parameters
eoo=0       # end of options reached

while [[ $1 ]]
do
    if ! ((eoo)); then
	case "$1" in
	  --pid)
	      shift
	      ;;
	  --)
	      eoo=1
	      options+=("$1")
	      shift
	      ;;
	  *)
	      options+=("$1")
	      shift
	      ;;
	esac
    else
	options+=("$1")
	shift
    fi
done

exec /cvmfs/oasis.opensciencegrid.org/mis/singularity/bin/singularity "${options[@]}"

