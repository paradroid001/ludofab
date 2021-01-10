#!/usr/bin/env bash
cd jenkinsserver
docker build -t jenkinsserver .
cd ..
cd unity3dserver
docker build -t unity3dbuildserver .
cd ..
cd dotnet
docker build -t dotnetbuildserver .
cd ..