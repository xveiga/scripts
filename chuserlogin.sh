#!/bin/bash

# Quick & dirty script to change the username login on strange conditions
# (when its being used by the shell process or others that prevent this change).
# The script will kill all processes for the user, then quickly execute a nohup usermod to perform the change.
# It may cause damage to open files or active processes, and it also may not work first time. Be careful.
#
# Originally intended to customize the "pi" login on Raspbian on a running pi over ssh without modifying any other settings.
#
# THIS IS NOT SAFE, I AM NOT RESPONSIBLE IF YOU DO BREAK SOMETHING BY USING THIS SCRIPT. YOU'VE BEEN WARNED.
#
# x.veiga@udc.es, 14/09/2018

homefoldersroot="/home"

if [ "$#" -eq 1 ]; then
	origuser=$(whoami)
elif [[ ($# -eq 3 && $3 == "continue") ]]; then
	origuser="$2"
	killall --user $origuser && nohup usermod -l $1 -d $homefoldersroot/$1 -m $origuser > /dev/null
	exit 0
else
	echo "Wrong parameters. Usage: chusername [newuser]"
	exit 1
fi

echo "This action will change user $origuser to $1" 
echo "WARNING: It will kill all processes that your user is running and will probably log you out."
echo "Continue at your own risk!"

read -n1 -r -s -p "Press uppercase Y to continue..." key
if [ "$key" = 'Y' ]; then
	echo ""
	if [ "$(whoami)" != "root" ]; then
		exec sudo -- "$0" "$1" "$origuser" "continue"
	else
		killall --user $origuser && usermod -l $1 -d $homefoldersroot/$1 -m $origuser
	fi
else
	echo ""
	echo "Aborting..."
	exit 0
fi

echo "Done"
