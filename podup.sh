#!/bin/bash
set -e

NEWVERSION=$1
SPECNAME=$2

if [ -z $NEWVERSION -o -z $SPECNAME ];then
	echo "usage: podup.sh MMMediaProxy/0.1.8 MMMediaProxy.podspec"
	exit 1
fi

SPECVERSION=`pod ipc spec $SPECNAME | awk -F \" '{ if($2=="version") printf("%s\n",$4); }'`

sed -e "/version/s/${SPECVERSION}/${NEWVERSION}/g" $SPECNAME > $SPECNAME.new

rm $SPECNAME

mv $SPECNAME.new $SPECNAME