#!/usr/bin/env bash

#builds unity project

set -e #exit immediately on nonzero return commands
set -x #print traces of branches and loops

for i in "$@"
do
case $i in
    -w=*|--workspace=*)
    WORKSPACE="${i#*=}"
    shift # past argument=value
    ;;
    -u=*|--unity_src_root=*)
    UNITY_SRC_ROOT="${i#*=}"
    shift # past argument=value
    ;;
    -b=*|--build_path=*)
    BUILD_PATH="${i#*=}"
    shift # past argument=value
    ;;
    -i=*|--build_id=*)
    BUILD_ID="${i#*=}"
    shift # past argument=value
    ;;
    -t=*|--target_platform=*)
    TARGET_PLATFORM="${i#*=}"
    shift # past argument=value
    ;;
    -n=*|--package_name=*)
    PACKAGE_NAME="${i#*=}"
    shift # past argument=value
    ;;
    *|--default)
    DEFAULT=$i
    shift # past argument with no value
    ;;
    *)
          # unknown option
    ;;
esac
done

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
echo "Building $UNITY_SRC_ROOT to $UNITY_BUILD_PATH/$BUILD_FILE"

#At this point the BUILD_PATH exits, but make sure the unity build path exists.
mkdir -p $UNITY_BUILD_PATH

export TMP_SRC="/var/tmp/src"
#We will copy to a temporary source path, and delete it afterwards
export TMP_SRC_PATH="${TMP_SRC}${UNITY_SRC_ROOT}"
mkdir -p $TMP_SRC_PATH
cp -R $UNITY_SRC_ROOT/* $TMP_SRC_PATH

#xvfb-run --auto-servernum --server-args='-screen 0 640x480x24' \
#  /opt/Unity/Editor/Unity \
#    -projectPath $(pwd) \
#    -quit \
#    -batchmode \
#    -buildTarget $BUILD_TARGET \
#    -customBuildTarget $BUILD_TARGET \
#    -customBuildName $BUILD_NAME \
#    -customBuildPath $BUILD_PATH \
#    -customBuildOptions AcceptExternalModificationsToPlayer \
#    -executeMethod BuildCommand.PerformBuild \
#    -logFile

# BUILD TO TEMP BUILD PATH
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24' \
/opt/Unity/Editor/Unity \
 -batchmode \
 -nographics \
 -buildTarget $TARGET_PLATFORM \
 -projectPath $TMP_SRC_PATH \
 -customBuildPath $UNITY_BUILD_PATH/$BUILD_FILE \
 -quit \
 -executeMethod Pixeltron.Utils.BuildTools.PerformBuild \
 -logFile "$BUILD_PATH/UnityBuild_$PROJECT_NAME-$TARGET_PLATFORM.log"

UNITY_EXIT_CODE=$?

if [ $UNITY_EXIT_CODE -eq 0 ]; then
  echo "Run succeeded, no failures occurred";
elif [ $UNITY_EXIT_CODE -eq 2 ]; then
  echo "Run succeeded, some tests failed";
elif [ $UNITY_EXIT_CODE -eq 3 ]; then
  echo "Run failure (other failure)";
else
  echo "Unexpected exit code $UNITY_EXIT_CODE";
fi

echo "Checking destination for files"
ls -la $UNITY_BUILD_PATH
[ -n "$(ls -A $UNITY_BUILD_PATH)" ] # fail job if build folder is empty