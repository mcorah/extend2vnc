#!/bin/bash

####################################
#author and maintainer: Micah Corah
#
#feel free to use and modify this code as you wish
#
####################################


#defaults
GEOMS=('1280x720' '800x1200');
GEOM=${GEOMS[0]}
LOC="-east"
DISP_NUM=4 

#get env info
PREV_LOC=`cat .loc`
SERV_PROC=`pgrep Xvnc4`
X2VNC_PROC=`pgrep x2vnc`

#parse args
CTXT="none"
for i in $@
do
	if [[ ${i:0:1} == "-" ]]
	then
		#echo "form -*"
		case $i in
		-f)
			FORCE=1
			CTXT="f"
			;;
		#kill statements
		-k)
			KILL=1
			CTXT="k"
			;;
		#landscape mode
		-l)
			GEOM=${GEOMS[1]}
			CTXT="l"
			;;
		#locs
		-n)
			LOC='-north'
			CTXT="n"
			;;
		-s)
			LOC='-south'
			CTXT="s"
			;;
		-e)
			LOC='-east'
			CTXT="e"
			;;
		-w)
			LOC='-south'
			CTXT="w"
			;;
		#display num
		-d)
			
			CTXT="d"
			;;
		-h)
			echo "This script is located at: $0"
			cat README
			exit
			;;
		*)
			echo "bad arg: $i"
			echo "This script is located at: $0"
			cat README
			exit
			;;
		esac
	else
		case $CTXT in
		d)
			DISP_NUM=$i
			;;
		s)
			KILL="SOFT"
			CTXT="none"
			;;
		*)
			echo "bad arg: $i"
			echo "This script is located at: $0"
			cat README
			exit
			;;
		esac
	fi
done

GEOMLIST=""
for i in ${GEOMS[@]}
do
	GEOMLIST="$GEOMLIST -geometry $i"
done

#kill supercedes all other commands
if [[ "x$KILL" == "x1" ]]; then
	echo "killing"
	pkill x2vnc
	vncserver -kill :$DISP_NUM 
elif [[ "x$KILL" == "xSOFT" ]]; then
	#soft kill leaves server running, but kills access
	#useful if you want to continue a session but do not want access from main desktop session
	echo "executing soft kill"
	pkill x2vnc
else

	#start vnc server
	if [[ "x$SERV_PROC" == "x" || "x$FORCE" == "x1" ]]
	then
		if [[ "x$FORCE" == "x1" ]]
		then
			echo "killing vncserver"
			vncserver -kill :$DISP_NUM > /dev/null
		fi
		echo "starting vncserver"
		vncserver :$DISP_NUM -geometry $GEOM $GEOMLIST > /dev/null
	else
		echo "resize"
		xrandr -d :$DISP_NUM -s $GEOM
	fi
	
	#start vnc access/extension
	if [[ "x$X2VNC_PROC" == "x" || "x$PREV_LOC" != "x$LOC" || "x$FORCE" == "x1" ]]
	then
		pkill x2vnc
		echo $LOC > .loc
		x2vnc $LOC 127.0.0.1:$DISP_NUM -passwdfile ~/.vnc/passwd > /dev/null &
	fi
fi
