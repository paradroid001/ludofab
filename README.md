Steps:
src and build are meant to be empty and not checked into source control
unity3dserver should be built into an image called unity3dbuildserver
	Has 2019.4.0 installed
	Has OpenJDK 8
	Has Android build tools/platform tools etc
	User is unitybuild (uid=1000, pass=unitybuild)
jenkinsserver should be built into an image called jenkinsserver
	User is jenkins (uid=1000)
	Login for Jenkins web interface is jenkinsuser:jenkinsuser
dotnet should be build into an image called dotnetbuildserver
	User is dotnetbuild (uid=100, pass=dotnetbuild)
	Has mono-complete, msbuild
	Has dotnet core 3.1

jenkins checks out code to /src
jenkins runs a script which:
	does an ssh into dotnetbuildserver:
		build libs (dotnet build): any libraries needed by your game. Their sln/csproj should be set up to put the compiled binaries in your Unity Project in the right place.
		test libs (dotnet test): tests the libraries.
	does an ssh into unity3dbuildserver:
		build: does the unity build.
		You should have a

Notes:
1. Don't have VSCodium open on the checked out source while you're trying to build, it seems to interfere with the bind mounts and you get access denied errors in the PackageCache or the Temp/StagingArea
2. You need to log into jenkins server and ssh to both unityserver and dotnetbuildserver to establish the host key. Then sshpass will work.
3. You need to do the unity licensing stuff, see the process on wtanaka's page
- essentially fire up unity a certain way, get the XML output
- save it to an alf file, go to unity's licensing page, post it.
- download the ulf file, and it goes in /home/unitybuild/.local/share/unity3d/Unity/Unity_lic.ulf

Some conf from:
https://gitlab.com/gableroux/unity3d
https://github.com/wtanaka/docker-unity3d

https://stackoverflow.com/questions/59035543/how-to-execute-command-from-one-docker-container-to-another