FROM ubuntu:14.04
MAINTAINER Stefan Schwetschke <stefan@schwetschke.de>

ENV SSH_BASE_VERSION 2016-02-17

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd

ENV SSH_CONFIGURATION 2016-02-17

RUN mkdir /ssh
RUN mkdir /ssh.template

# SSH login fix: Inside the container, the login id attribute cannot be set. 
# Without the fix, user is kicked off after login
RUN perl -pi -e 's/^\s*session\s+required\s+pam_loginuid(.*)$/session optional pam_loginuid$1/g' /etc/pam.d/sshd

COPY sshd_config /etc/ssh/

COPY banner /ssh.template/banner.template
RUN chmod a=r /ssh.template/banner.template
RUN cp /ssh.template/banner.template /ssh.template/banner

# Space delimited list of VPN users. Usually only one user is needed
ENV VPNUSERS vpn

RUN for i in $VPNUSERS; do adduser --gecos "" --shell /bin/false --disabled-password --no-create-home  $i; done 
COPY authorized_keys /ssh.template/authorized_keys.template
RUN chmod a=r /ssh.template/authorized_keys.template
RUN for i in $VPNUSERS; do cp -v -p /ssh.template/authorized_keys.template /ssh.template/authorized_keys_${i}; done


# Generating new prime numbers for key exchange. The default numbers might be compromised.
# This will take about an hour, even on a fast server!
ENV SKIP_SERVER_PRIME_NUMBERS 0 

# This should only be used for debug purposes
ENV STORE_SERVER_KEYS_IN_CONTAINER 0

# Update of the binaries stored in the image
ENV SSH_UPDATE 2016-02-17

RUN apt-get update
RUN apt-get upgrade -y openssh-server

COPY run-ssh.sh /
RUN chmod +x /run-ssh.sh

EXPOSE 22022
VOLUME /ssh

ENTRYPOINT ["/bin/bash", "/run-ssh.sh"]
# Disable remote DNS lookups in sshd:
# 1. Add the parameter "-u0" (don't fill hostnames in the utmp user structure).
# 2. Add "UseDNS no" to the sshd_config file.
# Still there might be lookups when authorized_keys contains "from=..." clauses.
CMD ["/usr/sbin/sshd", "-De", "-u0"]
