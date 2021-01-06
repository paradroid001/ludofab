cd jenkinsserver
docker build -t jenkinsserver .
cd ..
cd unity3dserver
docker build -t unity3dserver .
cd ..
cd dotnet
docker build -t dotnetserver .
cd ..