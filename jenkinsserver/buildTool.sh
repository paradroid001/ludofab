#!/usr/bin/env bash

#builds a unity project
set -e #exit immediately on nonzero return commands
#set -x #print traces of branches and loops

#Arguments:
#-p=PROJECT_NAME
#-b=BUILD_ROOT
#-w=WORKSPACE (the root dir of the project)
#-t=TARGET_PLATFORM
#-i=BUILD_ID
#-n=PACKAGE_NAME
#-u=UNITY_PROJECT_DIR (relative dir for unity proj)
#-l=LIBS_SRC_ROOT (relative dir for libs. This option builds libs only)
#-s=LIBS_SEARCH_PATH (path to unity libs, only for -l option)
#-f=FRAMEWORK (framework to build libs against, onlu for -l option)
#Parse command line.

for i in "$@"
do
case $i in
    -p=*|--project_name=*)
    PROJECT_NAME="${i#*=}"
    shift # past argument=value
    ;;
    -b=*|--build_root=*)
    BUILD_ROOT="${i#*=}"
    shift # past argument=value
    ;;
    -w=*|--workspace=*)
    WORKSPACE="${i#*=}"
    shift # past argument=value
    ;;
    -t=*|--target_platform=*)
    TARGET_PLATFORM="${i#*=}"
    shift # past argument=value
    ;;
    -i=*|--build_id=*)
    BUILD_ID="${i#*=}"
    shift # past argument=value
    ;;
    -n=*|--package_name=*)
    PACKAGE_NAME="${i#*=}"
    shift # past argument=value
    ;;
    -u=*|--unity_project_dir=*)
    UNITY_PROJECT_DIR="${i#*=}"
    shift # past argument=value
    ;;
    -l=*|--lib_subdir=*)
    LIBS_SUBDIR="${i#*=}"
    shift # past argument=value
    ;;
    -f=*|--framework=*)
    FRAMEWORK="${i#*=}"
    shift # past argument=value
    ;;
    -s=*|--libs_search_path=*)
    LIBS_SEARCH_PATH="${i#*=}"
    shift # past argument=value
    ;;
    --default)
    DEFAULT=YES
    shift # past argument with no value
    ;;
    *)
          # unknown option
    ;;
esac
done

#echo "FILE EXTENSION  = ${EXTENSION}"
#echo "SEARCH PATH     = ${SEARCHPATH}"
#echo "LIBRARY PATH    = ${LIBPATH}"
#echo "DEFAULT         = ${DEFAULT}"


echo "Building project $PROJECT_NAME from $WORKSPACE"
export UNITY_SRC_ROOT=$WORKSPACE/$UNITY_PROJECT_DIR
echo "Unity source: $UNITY_SRC_ROOT"
#if [[ -z $UNITY_PROJECT_LIB_SUBDIRS ]]; then
#    echo 'No libs directory defined.'
#else
#    echo "Libs subdir: $UNITY_PROJECT_LIB_SUBDIRS"
#    #export LIBS_SRC_ROOT=$WORKSPACE/$UNITY_PROJECT_LIB_SUBDIR
#    #echo "Libs src root: $LIBS_SRC_ROOT"
#fi
echo "Target platform: $TARGET_PLATFORM"
echo "Build ID: $BUILD_ID"
export BUILD_PATH=$BUILD_ROOT/$PROJECT_NAME/$TARGET_PLATFORM/$BUILD_ID
mkdir -p $BUILD_PATH

if [[ -z $LIBS_SUBDIR ]]; then
# You're doing a unity build, not a libs build


echo "-== UNITY BUILD ==-"
sshpass -p 'unitybuild' ssh -t unitybuild@unity3dbuildserver "PROJECT_NAME=$PROJECT_NAME TARGET_PLATFORM=$TARGET_PLATFORM UNITY_SRC_ROOT=$UNITY_SRC_ROOT UNITY_BUILD_PATH=$UNITY_BUILD_PATH BUILD_FILE=$BUILD_FILE BUILD_PATH=$BUILD_PATH ./build.sh"
sshpass -p 'unitybuild' ssh -t unitybuild@unity3dbuildserver "/src/unitybuild.sh -u=$UNITY_SRC_ROOT -b=$BUILD_PATH -n=$PACKAGE_NAME -t=$TARGET_PLATFORM"
else
export LIBS_SRC_ROOT=$WORKSPACE/$LIBS_SUBDIR
#it's a libs build.
echo "-== LIB BUILD ==-"
echo "    Building $LIBS_SRC_ROOT with $FRAMEWORK"
#double quotes for "command" is important, interpolates exported vars.
#build path is only so the log can be written
#sshpass -p 'dotnetbuild' ssh -t dotnetbuild@dotnetbuildserver "cd $LIBS_SRC_ROOT && dotnet clean &> $BUILD_PATH/dotnet_build.log && dotnet build &> $BUILD_PATH/dotnet_build.log"
sshpass -p 'dotnetbuild' ssh -t dotnetbuild@dotnetbuildserver "/src/dotnetbuild.sh -l=$LIBS_SRC_ROOT -u=$UNITY_SRC_ROOT -f=$FRAMEWORK -s=$LIBS_SEARCH_PATH clean &> $BUILD_PATH/dotnet_clean.log"
sshpass -p 'dotnetbuild' ssh -t dotnetbuild@dotnetbuildserver "/src/dotnetbuild.sh -l=$LIBS_SRC_ROOT -u=$UNITY_SRC_ROOT -f=$FRAMEWORK -s=$LIBS_SEARCH_PATH build &> $BUILD_PATH/dotnet_build.log"
#could put a line in here which cats a grep of the build log for success / error / warning
echo "-== LIB TEST ==-"
sshpass -p 'dotnetbuild' ssh -t dotnetbuild@dotnetbuildserver "/src/dotnetbuild.sh -l=$LIBS_SRC_ROOT -u=$UNITY_SRC_ROOT -f=$FRAMEWORK -s=$LIBS_SEARCH_PATH test &> $BUILD_PATH/dotnet_test.log"

#could put a line in here which cats a grep of the build log for passed/failed
fi

#echo "Libs Build Step"
#if [[ -z $UNITY_PROJECT_LIB_SUBDIRS ]]; then
#    echo 'No libs defined: skipping'
#else
#    for val in $UNITY_PROJECT_LIB_SUBDIRS; do
#        echo "Building lib in $WORKSPACE/$val"
#        export LIBS_SRC_ROOT=$WORKSPACE/$val
#
#        #double quotes for "command" is important, interpolates exported vars.
#        #build path is only so the log can be written
#        sshpass -p 'dotnetbuild' ssh -t dotnetbuild@dotnetbuildserver "cd $LIBS_SRC_ROOT && dotnet clean &> $BUILD_PATH/dotnet_build.log && dotnet build &> $BUILD_PATH/dotnet_build.log"
#        #could put a line in here which cats a grep of the build log for success / error / warning
#        echo "Libs Test Step"
#        sshpass -p 'dotnetbuild' ssh -t dotnetbuild@dotnetbuildserver "cd $LIBS_SRC_ROOT && dotnet test &> $BUILD_PATH/dotnet_test.log"
#        #could put a line in here which cats a grep of the build log for passed/failed
#    done
#    
#fi
#echo "Unity build Step"
#sshpass -p 'unitybuild' ssh -t unitybuild@unity3dbuildserver "PROJECT_NAME=$PROJECT_NAME TARGET_PLATFORM=$TARGET_PLATFORM UNITY_SRC_ROOT=$UNITY_SRC_ROOT UNITY_BUILD_PATH=$UNITY_BUILD_PATH BUILD_FILE=$BUILD_FILE BUILD_PATH=$BUILD_PATH ./build.sh"

