#!/bin/bash

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
		echo "form -*"
		case $i in
		-f)
			echo "force"
			FORCE=1
			CTXT="f"
			;;
		-k)
			echo "kill"
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
			cat README
			exit
			;;
		*)
			echo "bad xarg: $i"
			cat README
			exit
			;;
		esac
	else
		case $CTXT in
		d)
			DISP_NUM=$i
			;;
		*)
			echo "bad arg: $i"
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

if [[ "x$KILL" == "x1" ]]
then
	echo "killing"
	pkill x2vnc
	vncserver -kill :$DISP_NUM 
	exit
fi

if [[ "x$SERV_PROC" == "x" || "x$FORCE" == "x1" ]]
then
	echo "starting"
	if [[ "x$FORCE" == "x1" ]]
	then
		vncserver -kill :$DISP_NUM
	fi
	vncserver :$DISP_NUM -geometry $GEOM $GEOMLIST &
else
	echo "resize"
	xrandr -d :$DISP_NUM -s $GEOM
fi

if [[ "x$X2VNC_PROC" == "x" || "x$PREV_LOC" != "x$LOC" || "x$FORCE" == "x1" ]]
then
	pkill x2vnc
	echo $LOC > .loc
	x2vnc $LOC 127.0.0.1:$DISP_NUM -passwdfile ~/.vnc/pass &> /dev/null &
fi
