## LudoFab
### A build server for Unity in docker, with Jenkins

NOTE - on windows you want this repo set to autocrlf=false, like this:
git config core.autocrlf false

Otherwise you may need to siphon a few files (buildTool.sh, build.sh) through a sed command like this:
sed $'s/\r$//' ./buildTool.sh > ./buildToolCorrect.sh

### Setup of the checkout:
- mounts are the bind mounts that will happen on docker-compose up
	- src and build are meant to be empty and not checked into source control.
	- src is where project source code will be checked out
	- build is where project builds will end up.
	- home is mainly for the unityhome user's home directory, and is a bind mount mostly so we can just dump in the unity licensing info.

- unity3dserver should be built into an image called unity3dbuildserver
	- Has 2019.4.0 installed
	- Has OpenJDK 8
	- Has Android build tools/platform tools etc
	- User is unitybuild (uid=1000, pass=unitybuild)
- jenkinsserver should be built into an image called jenkinsserver
	- User is jenkins (uid=1000)
	- Login for Jenkins web interface is jenkinsuser:jenkinsuser
- dotnet should be build into an image called dotnetbuildserver
	- User is dotnetbuild (uid=100, pass=dotnetbuild)
	- Has mono-complete, msbuild
	- Has dotnet core 3.1

### Getting started
1. Build the three images in each of their directories.
	docker build -t jenkinsserver . (takes about 5 minutes)
	docker build -t dotnetbuildserver . (takes about 30 mins+)
	docker built -t unity3dbuildserver . (takes at least an hour)
2. Bring the stack up: docker-compose up -d
3. exec into the jenkinsserver container and ssh to the others to set up the host keys:
	ssh -t unitybuild@unity3dbuildserver
	ssh -t dotnetbuild@dotnetbuildserver
4. exec into the unity3dbuildserver container, su to unitybuild, and try to run Unity to set up licensing (as explained here: https://github.com/wtanaka/docker-unity3d)
	```
	xvfb-run --auto-servernum --server-args='-screen 0 640x480x24' \
/opt/Unity/Editor/Unity \
-logFile activate.log \
-batchmode \
-username "$UNITY_USERNAME" -password "$UNITY_PASSWORD"
	```
	Grab the xml (will be in activate.log), save to unity3d.alf (this step can be a pain - make sure uname/pwd are double quoted and escape any shell meta chars)
	Go to https://licence.unity3d.com/manual, upload the file, answer the questions
	Save the resulting file in /home/unitybuild/.local/share/unity3d/Unity/Unity_lic.ulf
5. Now you're ready to configure jenkins. Make a freeform job, manually set the workspace to /src/projectname, and configure the git checkout. Don't delete between builds. extra build step is to run:
```
WORKSPACE=$WORKSPACE \
PROJECT_NAME=<your project name> \
UNITY_PROJECT_DIR=<subdir name that holds the unity project> \
UNITY_PROJECT_LIB_SUBDIR=<subdir name that holds c# lib code> \
TARGET_PLATFORM=Win64 \
BUILD_ID=$BUILD_ID \
BUILD_ROOT=/builds \
PACKAGE_NAME=<destination build directory root> \
~/buildTool.sh
```



### What the build scripts do
- jenkins checks out code to /src
- jenkins runs a script which:
	does an ssh into dotnetbuildserver:
		build libs (dotnet build): any libraries needed by your game. Their sln/csproj should be set up to put the compiled binaries in your Unity Project in the right place.
		test libs (dotnet test): tests the libraries.
	does an ssh into unity3dbuildserver:
		build.sh: does the unity build by copying the source to /var/tmp, building, and copying the result back. 

### Notes:
1. Don't have VSCodium open on the checked out source while you're trying to build, it seems to interfere with the bind mounts and you get access denied errors in the PackageCache or the Temp/StagingArea. UPDATE: this seemed to have been happening because the build really happens in the Temp area of a unity project. The scripts now copy the project to a different location in /var/temp, build it, and copy the build back.

Some conf from:
https://gitlab.com/gableroux/unity3d
https://github.com/wtanaka/docker-unity3d

https://stackoverflow.com/questions/59035543/how-to-execute-command-from-one-docker-container-to-another