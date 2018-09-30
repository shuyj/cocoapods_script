#!/bin/bash
set -e

NEWVERSION=$1

if [ -z $NEWVERSION ];then
	echo "podupdate.sh newVersion; example podupdate.sh 0.1.9"
	exit 1
fi

WORKDIR=`pwd`

# 1. compile  进到xcode工程目录
cd ../../ProxyPlayer/ios/MMMediaProxy
echo " COMPILE ======= "
# 指定要编译的TARGET，默认编译Release
xcodebuilduniversal.sh MMMediaProxy
echo " COPY ======= PRODUCT "

# 拷贝universal的结果到要发布的git库中
rm -rf $WORKDIR/framework/*
cp -rf build/Release-universal/* $WORKDIR/framework/
set +e
echo " CODE-GIT ======= NEW-TAG "
# 打新标签
git tag "MMMediaProxy/$NEWVERSION"
git push --tags
set -e
cd $WORKDIR
# 提交新的库文件
echo " POD-GIT ======= COMMIT "
git add -A
git commit -m "pod update $NEWVERSION"
git push

echo " POD ======= UPDATE "
# 新增Pod的Git库标签，与修改podspec文件的版本号
podup.sh $NEWVERSION MMMediaProxy.podspec
echo " POD-GIT ======= NEW-TAG "
# 打新标签
git tag "MMMediaProxy/$NEWVERSION"
git push --tags
echo " POD ======= PUSH "
# 发布podspec到远端的repo中
podpush.sh -spec MMMediaProxy.podspec -repo repo_name -force -json

echo " POD ======= DONE "

cat $WORKDIR/framework/MMMediaProxy.framework/version.txt