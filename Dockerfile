FROM karthikb21/jenkins-agent:maven1.2
USER root
RUN apt-get update && apt-get install -y awscli
USER jenkins