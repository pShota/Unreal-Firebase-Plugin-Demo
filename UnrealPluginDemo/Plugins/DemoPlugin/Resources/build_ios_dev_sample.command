#!/bin/sh

####please change to your path
UE_ENGINE="/Users/Shared/Epic Games/UE_4.25/Engine/Binaries/Mac/UE4Editor.app/Contents/MacOS/UE4Editor"
RUNUAT="/Users/Shared/Epic Games/UE_4.25/Engine/Build/BatchFiles/RunUAT.sh"
PLATFORM="IOS"
BuildFolder="/Users/philip/workspace/BuildFolder"
TargetName="UnrealPluginDemo"
Config="Development" # or Shipping

curr_dir=`dirname "$0"`
curr_dir=`( cd "$curr_dir" && pwd )`
cd $curr_dir
UProject="$curr_dir/../../../$TargetName.uproject"

#text style
tred=`tput setaf 1`
tmagenta=`tput setaf 5`
treset=`tput sgr0`

###common function
check_error()
{
	error=$?
	if [ $error -ne 0 ] ; then
	  echo "${tred}command failed: we have an exit code of $error${treset}"
	  exit 1
	fi
}

echo "${tmagenta}Build iOS with entitlement fix Sample${treset}"
echo "Run UE4 build script"
echo ""

bash "$RUNUAT" \
-ScriptsForProject="$UProject" \
BuildCookRun \
-nocompileeditor \
-installed \
-nop4 \
-project="$UProject" \
-cook \
-stage \
-archive \
-archivedirectory="$BuildFolder" \
-package \
-ue4exe="$UE_ENGINE" \
-pak \
-prereqs \
-nodebuginfo \
-targetplatform="$PLATFORM" \
-build \
-target="$TargetName" \
-clientconfig="$Config" \
-utf8output

check_error

echo ""
echo "${tmagenta}Run Entitlement fix script${treset}"

bash iOS_add_entitlements_manually.sh "$BuildFolder" "$Config" "$TargetName"