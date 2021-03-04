#!/bin/bash



#text style
tred=`tput setaf 1`
tmagenta=`tput setaf 5`
treset=`tput sgr0`

###common function

check_error()
{
	error=$?
	if [ $error -ne 0 ] ; then
	  echo "${tred}xcent entitlement file isnt generated yet, please rebuild iOS again!(it will work on 2nd build)${treset}"
	  exit 0
	fi
}


echo "${tmagenta}"
echo "UnrealPluginDemo Plugins Post Script Run"
curr_dir=`dirname "$0"`
curr_dir=`( cd "$curr_dir" && pwd )`
echo "script location:$curr_dir"

APPNAME="$1"
Config="$2"
ProjectDir="$3"
TargetPlatform="$4"

echo "Config: ${Config}"
echo "TargetPlatform: ${TargetPlatform}${treset}"



if [ "$TargetPlatform" != "IOS" ];
then
    echo "${tmagenta}Not building iOS, exit${treset}"
    echo ""
    exit 0
fi




cd "$ProjectDir/Intermediate/ProjectFilesIOS/build/${APPNAME}.build/${Config}-iphoneos/${APPNAME}.build"
check_error

echo "modify ${APPNAME}.app.xcent"


#add rows to entitlements.plist
#allow Push notification
if [ "$Config" = "Shipping" ];
then
    plutil -insert "aps-environment" -string "production" "${APPNAME}.app.xcent"
else
    plutil -insert "aps-environment" -string "development" "${APPNAME}.app.xcent"
fi

#allow Testflight build
if [ "$Config" = "Shipping" ];
then
    plutil -insert "beta-reports-active" -bool true "${APPNAME}.app.xcent"
fi

echo "${tmagenta}"
cat "${APPNAME}.app.xcent"
echo "${treset}"