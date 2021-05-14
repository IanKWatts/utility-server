FROM registry.access.redhat.com/ubi8/ubi
RUN yum -y update && yum -y install git jq nmap-ncat python38-pip unzip && pip3 install github-backup && mkdir /scripts /backups
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install
#RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install
COPY scripts/* /scripts/
