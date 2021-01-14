# Extend Jenkins LTS
FROM jenkins/jenkins:lts

# Print kernel and distro info
RUN echo "Distro info:" && uname -a && cat /etc/*release

USER root
RUN apt-get update
#we want this so we can ssh to the unity build server
RUN apt-get install sshpass

ADD buildTool.sh /src/
RUN chown jenkins:jenkins /src/buildTool.sh

# Switch back to jenkins user
USER jenkins

#fix build tool line endings if cloned on windows machine
RUN sed $'s/\r$//' /src/buildTool.sh > /src/buildToolCorrect.sh \
&& mv /src/buildToolCorrect.sh /src/buildTool.sh \
&& chmod +x /src/buildTool.sh

