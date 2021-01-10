#!/usr/bin/env bash

#builds a unity project
set -e #exit immediately on nonzero return commands
set -x #print traces of branches and loops

echo "Building project $PROJECT_NAME from $WORKSPACE"
export UNITY_SRC_ROOT=$WORKSPACE/$UNITY_PROJECT_DIR
echo "Unity source: $UNITY_SRC_ROOT"
if [[ -z $UNITY_PROJECT_LIB_SUBDIR ]]; then
    echo 'No libs directory defined.'
else
    echo "Libs subdir: $UNITY_PROJECT_LIB_SUBDIR"
    export LIBS_SRC_ROOT=$WORKSPACE/$UNITY_PROJECT_LIB_SUBDIR
    echo "Libs src root: $LIBS_SRC_ROOT"
fi
echo "Target platform: $TARGET_PLATFORM"
echo "Build ID: $BUILD_ID"
export BUILD_PATH=$BUILD_ROOT/$PROJECT_NAME/$TARGET_PLATFORM/$BUILD_ID
export BUILD_FILE="Unknown"
if [ "$TARGET_PLATFORM" = "Win" ]; then
    export BUILD_FILE="${PACKAGE_NAME}.exe";
elif [ "$TARGET_PLATFORM" = "Win64" ]; then
    export BUILD_FILE="${PACKAGE_NAME}.exe"
elif [ "$TARGET_PLATFORM" = "OSX" ]; then
    export BUILD_FILE="${PACKAGE_NAME}.app"
elif [ "$TARGET_PLATFORM" = "Linux64" ]; then
    export BUILD_FILE="${PACKAGE_NAME}.x64"
elif [ "$TARGET_PLATFORM" = "Android" ]; then
    export BUILD_FILE="${PACKAGE_NAME}.apk"
elif [ "$TARGET_PLATFORM" = "WebGL" ]; then
    export BUILD_FILE="${PACKAGE_NAME}"
else
    echo "No recognised target platform" && exit 1
fi

export UNITY_BUILD_PATH=$BUILD_PATH/$PACKAGE_NAME
echo "Building to: $UNITY_BUILD_PATH/$BUILD_FILE"

mkdir -p $BUILD_PATH

echo "Libs Build Step"
if [[ -z $UNITY_PROJECT_LIB_SUBDIR ]]; then
    echo 'No libs defined: skipping'
else
    #double quotes for "command" is important, interpolates exported vars.
    #build path is only so the log can be written
    sshpass -p 'dotnetbuild' ssh -t dotnetbuild@dotnetbuildserver "cd $LIBS_SRC_ROOT && dotnet clean &> $BUILD_PATH/dotnet_build.log && dotnet build &> $BUILD_PATH/dotnet_build.log"
    #could put a line in here which cats a grep of the build log for success / error / warning
    echo "Libs Test Step"
    sshpass -p 'dotnetbuild' ssh -t dotnetbuild@dotnetbuildserver "cd $LIBS_SRC_ROOT && dotnet test &> $BUILD_PATH/dotnet_test.log"
    #could put a line in here which cats a grep of the build log for passed/failed
    
fi
echo "Unity build Step"
sshpass -p 'unitybuild' ssh -t unitybuild@unity3dbuildserver "PROJECT_NAME=$PROJECT_NAME TARGET_PLATFORM=$TARGET_PLATFORM UNITY_SRC_ROOT=$UNITY_SRC_ROOT UNITY_BUILD_PATH=$UNITY_BUILD_PATH BUILD_FILE=$BUILD_FILE BUILD_PATH=$BUILD_PATH ./build.sh"

