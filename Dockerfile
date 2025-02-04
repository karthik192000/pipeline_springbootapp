FROM karthikb21/jenkins-agent:maven1.0
USER root
RUN apt-get update && apt-get install -y docker.io && apt-get install systemctl -y
CMD ["systemctl start docker.io","systemctl enable docker"]