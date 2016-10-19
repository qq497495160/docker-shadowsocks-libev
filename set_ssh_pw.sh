#!/bin/bash

if [ -f /.ssh_pw_set ]; then
  echo "Root password already set!"
  exit 0
fi

PASS=${SSH_PASSWORD:-$(pwgen -s 12 1)}
_word=$( [ ${SSH_PASSWORD} ] && echo "preset" || echo "random" )
echo "=> Setting a ${_word} password to the ssh_user"
useradd ssh_user
echo "ssh_user:$PASS" | chpasswd
echo "ssh_user   ALL=(ALL)       ALL" >> /etc/sudoers
# 把ssh_user用户的shell改成bash，否则SSH登录服务器，命令行不显示用户名和目录 
usermod -d / -s /bin/bash ssh_user

echo "=> Done!"
touch /.ssh_pw_set

echo "========================================================================"
echo "You can now connect to this Debian container via SSH using:"
echo ""
echo "    ssh -p <port> ssh_user@<host>"
echo "and enter the ssh_user password '$PASS' when prompted"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "========================================================================"
