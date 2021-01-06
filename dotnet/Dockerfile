FROM ubuntu:20.04

# Print kernel and distro info
RUN echo "Distro info:" && uname -a && cat /etc/*release

USER root

RUN apt-get update

# Install needed tools and upgrade installed packages
RUN apt-get install -y --no-install-recommends \
curl apt-transport-https software-properties-common gnupg2 wget \
&& apt-get upgrade -y



# Add Microsoft repository for .NET SDK
#RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
#RUN apt-add-repository https://packages.microsoft.com/debian/9/prod/

#installing dotnet as according to:
# https://tecadmin.net/how-to-install-net-core-on-ubuntu-20-04/
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb \
&& dpkg -i packages-microsoft-prod.deb

# Install .NET SDK
RUN apt-get update \
&& apt-get install -y dotnet-sdk-3.1

#TO INSTALL MSBUILD

RUN apt install gnupg ca-certificates \
&& apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
&& echo "deb https://download.mono-project.com/repo/ubuntu preview-focal main" | tee /etc/apt/sources.list.d/mono-official-preview.list \
&& apt update

# if the packages were already installed
RUN apt upgrade

# otherwise
RUN apt install -y mono-complete msbuild

#cleanup
RUN rm *.deb

#create unitybuild user
RUN useradd -m --no-log-init --system --uid 1000 dotnetbuild -s /bin/bash -g sudo -G root
#set the password to dotnetbuild
run echo 'dotnetbuild:dotnetbuild' | chpasswd

RUN apt install -y openssh-server

#so sshd can run
RUN mkdir /run/sshd
