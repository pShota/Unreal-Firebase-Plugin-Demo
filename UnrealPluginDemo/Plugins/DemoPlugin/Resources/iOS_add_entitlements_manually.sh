#!/bin/bash
#please change to your path
BuildFolder="/Users/philip/workspace/BuildFolder/IOS" #default value, will set by paramter $1
Config="Development" #default value, will set by parameter $2
TargetName="UnrealPluginDemo" #default value, will set by parameter $3

#text style
tred=`tput setaf 1`
tmagenta=`tput setaf 5`
treset=`tput sgr0`

curr_dir=`dirname "$0"`
curr_dir=`( cd "$curr_dir" && pwd )`

###common function
check_error()
{
	error=$?
	if [ $error -ne 0 ] ; then
	  echo "${tred}command failed: we have an exit code of $error${treset}"
	  exit 1
	fi
}



echo "UnrealPluginDemo Plugins Post Script Run"

echo "${tmagenta}Fetching Certificate name from DefaultGame.ini${treset}"
SettingCertStr=`strings "$curr_dir/../../../Config/DefaultEngine.ini" | grep "SigningCertificate"`
if [[ $string == *"error"* ]]; then
  echo "${tred}Cannot find DefaultGame.ini, wrong path${treset}"
  exit 1
fi
SettingCertStr=`echo "$SettingCertStr" | cut -c20-${#SettingCertStr}`
echo "Using Certificate:$SettingCertStr"



#check if parameter exist
if [ -z ${1+x} ];
then 
    echo "BuildFolder: $BuildFolder"
    echo "Config: $Config"
    echo "TargetName: $TargetName"
else
    BuildFolder="$1/IOS"
    Config="$2"
    TargetName="$3"
    echo "BuildFolder: $BuildFolder"
    echo "Config: $2"
    echo "TargetName: $3"
fi

#script start
cd ${BuildFolder}
check_error

AppName="${TargetName}"
if [ "$Config" = "Shipping" ];
then
    AppName="${TargetName}-IOS-Shipping"
fi


#unpack built ipa
echo "unzip ipa.."
unzip -qu ${AppName}.ipa
check_error

#export original entitlemetnt
echo "edit entitlements.."
codesign -d --entitlements :- "Payload/${TargetName}.app" > entitlements.plist
check_error

#add rows to entitlements.plist
#allow Push notification
if [ "$Config" = "Shipping" ];
then
    plutil -insert "aps-environment" -string "production" entitlements.plist
else
    plutil -insert "aps-environment" -string "development" entitlements.plist
fi


#allow Testflight build
if [ "$Config" = "Shipping" ];
then
    plutil -insert "beta-reports-active" -bool true entitlements.plist
fi

#check if Frameworks exist, unreal support iOS dynamic library now?
#if yes please let me know, philip.so@6waves.com
if [ -d "./Payload/${TargetName}.app/Frameworks" ] 
then
    echo "resign Frameworks folder.."
    rm -rf "Payload/${TargetName}.app/Frameworks/*/_CodeSignature"
    for entry in "./Payload/${TargetName}.app/Frameworks"/*
    do
        # echo "$entry"
        codesign --entitlements entitlements.plist -f -s "${SettingCertStr}" "${entry}"
    done
fi
#resign ipa
echo "resign ipa.."
codesign --entitlements entitlements.plist -f -s "${SettingCertStr}" "Payload/${TargetName}.app"
check_error

echo "new entitlements with followings.."
codesign -d --entitlements :- "Payload/${TargetName}.app"
check_error

#remove old ipa
rm -f ${AppName}.ipa

#zip ipa
echo "zip ipa.."
zip -qr ${AppName}.ipa Payload

echo "clean up.."
#clean up
rm -rf Payload
rm -f entitlements.plist
echo "Resign completed!"