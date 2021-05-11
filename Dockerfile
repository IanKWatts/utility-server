FROM centos:centos8
RUN yum -y install curl git jq nmap-ncat python38-pip which && pip3 install github-backup && mkdir /scripts
COPY scripts/* /scripts/
