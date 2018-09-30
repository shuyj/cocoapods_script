#!/bin/bash
set -e

WORKDIR=`pwd`
SPECNAME=
REPONAME=
ISJSON=
VERBOSE=
SPECVERSION=
SPECBASENAME=
LOCAL=
VALIDATION='--skip-import-validation --skip-tests --quick'
STATIC=
FORCE=0
while [ $# -gt 0 ];do
    case $1 in
        -static)
		shift
		STATIC='--use-libraries'
		;;
		-spec)
		SPECNAME=$2
		SPECBASENAME=${SPECNAME%%\.podspec}
		SPECVERSION=`pod ipc spec $SPECNAME | awk -F \" '{ if($2=="version") printf("%s\n",$4); }'`
		shift 2
		;;
		-repo)
		REPONAME=$2
		shift 2
		;;
		-check)
		shift
		VALIDATION=
		;;
		-json)
		shift
		ISJSON='--use-json'
		;;
		-v)
		shift
		VERBOSE='--verbose'
		set -x
		;;
		-local)
		shift
		LOCAL='--local-only'
		;;
		-force)
		shift
		FORCE=1
		;;
		*)
		echo "ignore -- $1"
		shift
		;;
	esac
done

function usage()
{
	echo "usage: podpush 
		-spec xxx.podspec 
		-repo push-reponame 
		-static use-libraries 
		-check validation library 
		-json json format spec
		-force  force push whitout validation
		-local  only push to local repos
		-v verbose"
}

function manual_push_repo()
{
	echo "Publish repo, manual"
	# 进入Specs的Git目录
	cd ~/.cocoapods/repos/$REPONAME
	# git pull 拉取最新代码
	git pull
	set +e
	# 创建与spec同名的目录与版本号文件夹
	mkdir -p $SPECBASENAME/$SPECVERSION
	set -e
	# 拷贝spec文件到文件目录下
	if [ -z $ISJSON ]; then
		cp $WORKDIR/$SPECNAME $SPECBASENAME/$SPECVERSION
		git add $SPECBASENAME/$SPECVERSION/$SPECNAME
	else
		pod ipc spec $WORKDIR/$SPECNAME > $SPECBASENAME/$SPECVERSION/$SPECNAME.json
		git add $SPECBASENAME/$SPECVERSION/$SPECNAME.json
	fi
	# 提交并推送
	git commit -m "[Update] $SPECBASENAME ($SPECVERSION)"
	# 推送
	if [ -z $LOCAL ];then
		git push 	
		echo "publish done"
	else
		echo "no publish"
	fi
	cd $WORKDIR
}

function pod_push_repo()
{
	echo "Publish repo, $REPONAME $SPECNAME $ISJSON $LOCAL --allow-warnings --skip-import-validation --skip-tests $STATIC $VERBOSE"
	pod repo push --sources='https://github.com/CocoaPods/Specs.git' $REPONAME $SPECNAME $ISJSON $LOCAL --allow-warnings --skip-import-validation --skip-tests $STATIC $VERBOSE
}

if [ -z $SPECNAME ];then
	usage
	exit 1
fi
echo "Valid spec, $SPECNAME --allow-warnings --fail-fast $VALIDATION $STATIC $VERBOSE"

pod spec lint --sources='https://github.com/CocoaPods/Specs.git' $SPECNAME --allow-warnings --fail-fast $VALIDATION $STATIC $VERBOSE

if [ -z $REPONAME ];then
	usage
	pod repo list
	exit 2
fi
if [ $FORCE == 1 ];then
	manual_push_repo
else
	pod_push_repo
fi
