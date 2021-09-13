#FROM registry.access.redhat.com/ubi8/ubi
FROM registry.access.redhat.com/ubi8-init
#RUN yum -y update && yum -y install git jq mailx nmap-ncat postfix python38-pip unzip && pip3 install github-backup && mkdir /scripts /backups
RUN yum -y install mailx postfix && mkdir /scripts /backups
#RUN curl "https://dl.min.io/client/mc/release/linux-amd64/mc" -o /usr/local/bin/mc && chmod +x /usr/local/bin/mc
#RUN curl "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz" -o oc.tar.gz && tar xzf oc.tar.gz && mv oc /usr/local/bin && chmod +x /usr/local/bin/oc && rm oc.tar.gz
RUN mkdir /etc/systemd/system/postfix.service.d/; echo -e '[Service]\nRestart=always' > /etc/systemd/system/postfix.service.d/postfix.conf
RUN systemctl enable postfix
RUN sed -i 's/^smtp      inet/2525      inet/' /etc/postfix/master.cf
COPY tools/github-backups/scripts/* /scripts/
CMD [ "/sbin/init" ]
