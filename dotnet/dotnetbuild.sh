#!/usr/bin/env bash

#builds a dotnet project
#Needs the following:
#BUILD_PATH = path to final build location for project (for logs)
#LIB_DIR = path to the root of the libs to be built (where the sln is)
#UNITY_PROJECT = path to the unity project that these libs will end up in
#DOTNETFW = string for the .NET framework to use, e.g. net471 net48 netcoreapp3.1
#DLLPATH = path to unity dlls on the build system
set -e #exit immediately on nonzero return commands
#set -x #print traces of branches and loops

for i in "$@"
do
case $i in
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
    *|--default)
    DEFAULT=$i
    shift # past argument with no value
    ;;
    *)
          # unknown option
    ;;
esac
done

if [[ -n $DEFAULT ]]; then
    COMMAND=$DEFAULT
else
    echo "No command (clean|build|test) specified"
    exit 1
fi

export DEST_DIR=$UNITY_PROJECT_DIR/Assets/plugins
echo "Performing $COMMAND on $LIBS_SUBDIR into $DEST_DIR using $FRAMEWORK and $LIBS_SEARCH_PATH"
cd $LIBS_SUBDIR
dotnet $COMMAND -p:"TFW=$FRAMEWORK;UnityProject=$DEST_DIR;DLLPath=$LIBS_SEARCH_PATH"