FROM buildpack-deps:jessie-scm

# 签名
MAINTAINER saymagic "zhuxiaole@zhuxiaole.org"

#安装ssh服务
# Install packages
RUN apt-get update && apt-get -y install openssh-server pwgen && \
    mkdir -p /var/run/sshd && \
    sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/PermitRootLogin without-password/PermitRootLogin yes/g" /etc/ssh/sshd_config

ADD set_ssh_pw.sh /set_ssh_pw.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh

ENV AUTHORIZED_KEYS **None**

ENV DEPENDENCIES git-core build-essential autoconf libtool libssl-dev libpcre3-dev asciidoc xmlto
ENV BASEDIR /tmp/shadowsocks-libev
ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 8388
ENV SS_PASSWORD password
ENV METHOD aes-256-cfb
ENV TIMEOUT 300
ENV VERSION v2.5.5

# Set up building environment
RUN apt-get update \
 && apt-get install --no-install-recommends -y $DEPENDENCIES

# Get the latest code, build and install
RUN git clone https://github.com/shadowsocks/shadowsocks-libev.git $BASEDIR
WORKDIR $BASEDIR
RUN git checkout $VERSION \
 && ./configure \
 && make \
 && make install

# Tear down building environment and delete git repository
WORKDIR /
RUN rm -rf $BASEDIR/shadowsocks-libev\
 && apt-get --purge autoremove -y $DEPENDENCIES

EXPOSE 22
EXPOSE $SERVER_PORT/tcp
EXPOSE $SERVER_PORT/udp

CMD ["/run.sh"]