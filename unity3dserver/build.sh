#!/usr/bin/env bash

set -e
set -x

echo "Building $PROJECT_NAME for $TARGET_PLATFORM"
echo "Build file is: $BUILD_FILE"
echo "Build path is: $UNITY_BUILD_PATH"
echo "Unity Project is in $UNITY_SRC_ROOT"

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
 -executeMethod BuildScript.PerformBuild \
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