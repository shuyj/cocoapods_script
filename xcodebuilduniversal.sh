#!/bin/bash

COMPILETARGET=$1
if [ -z $COMPILETARGET ];then
	echo "usage: xcodebuilduniversal.sh target -universal"
	exit 1
fi
shift

UNIVERSAL=0
while [ $# -gt 0 ];do
    case $1 in
        -universal)
		shift
		UNIVERSAL=1
		;;
		*)
		echo "ignore -- $1"
		shift
		;;
	esac
done

BUILD_DIR=`pwd`/build
CONFIGURATION=Release

UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal

xcodebuild -target ${COMPILETARGET} -configuration ${CONFIGURATION} ONLY_ACTIVE_ARCH=NO BUILD_DIR="${BUILD_DIR}" -sdk iphoneos
if [ $UNIVERSAL == 1 ];then
	xcodebuild -target ${COMPILETARGET} -configuration ${CONFIGURATION} ONLY_ACTIVE_ARCH=NO BUILD_DIR="${BUILD_DIR}" -sdk iphonesimulator
fi

mkdir -p ${UNIVERSAL_OUTPUTFOLDER}

cp -v -f -r "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${COMPILETARGET}.framework" "${UNIVERSAL_OUTPUTFOLDER}"

if [ $UNIVERSAL == 1 ];then
	lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${COMPILETARGET}.framework/${COMPILETARGET}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${COMPILETARGET}.framework/${COMPILETARGET}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${COMPILETARGET}.framework/${COMPILETARGET}"
fi