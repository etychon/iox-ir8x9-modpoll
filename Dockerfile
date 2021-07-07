FROM alpine:3.8

# This will generate the right IOx package.yaml at build time
LABEL cisco.descriptor-schema-version="2.12" \
      cisco.resources.profile=custom \
      cisco.resources.cpu="200" \
      cisco.resources.memory="128" \
      cisco.resources.disk="10" \
      cisco.resources.network.0.interface-name=eth0 \
      cisco.resources.network.0.ports.tcp=[22] \
      cisco.info.version="1.0" \
      cisco.info.author-name="Emmanuel Tychon <etychon@cisco.com>" \
      cisco.info.author-link="https://github.com/etychon/" \
      cisco.info.description="SSH login root/root to access shell with modpoll"

# This will be the root user password to use with SSH
ARG PASSWORD=root

# Installing the openssh and bash package, removing the apk cache
RUN apk --update add --no-cache openssh bash procps net-tools busybox-extras \
  && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
  && echo "root:${PASSWORD}" | chpasswd \
  && rm -rf /var/cache/apk/*

# Defining the Port 22 for service
RUN sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
RUN /usr/bin/ssh-keygen -A
RUN ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Add the modpoll binary
ADD bin/modpoll /bin

EXPOSE 22

# Let's rock
CMD ["/usr/sbin/sshd", "-D"]
