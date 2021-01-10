# Extend Jenkins LTS
FROM jenkins/jenkins:lts

# Print kernel and distro info
RUN echo "Distro info:" && uname -a && cat /etc/*release

USER root
RUN apt-get update
#we want this so we can ssh to the unity build server
RUN apt-get install sshpass

ADD buildTool.sh /var/jenkins_home
RUN chown jenkins:jenkins /var/jenkins_home/buildTool.sh

# Switch back to jenkins user
USER jenkins

#fix build tool line endings if cloned on windows machine
RUN sed $'s/\r$//' /var/jenkins_home/buildTool.sh > /var/jenkins_home/buildToolCorrect.sh \
&& mv /var/jenkins_home/buildToolCorrect.sh /var/jenkins_home/buildTool.sh \
&& chmod +x /var/jenkins_home/buildTool.sh

