#!/bin/bash

if [ -f /.ssh_pw_set ]; then
  echo "Root password already set!"
  exit 0
fi

PASS=${SSH_PASSWORD:-$(pwgen -s 12 1)}
_word=$( [ ${SSH_PASSWORD} ] && echo "preset" || echo "random" )
echo "=> Setting a ${_word} password to the $SSH_USER"
useradd $SSH_USER
echo "$SSH_USER:$PASS" | chpasswd
echo "$SSH_USER   ALL=(ALL)       ALL" >> /etc/sudoers
# 把ssh_user用户的shell改成bash，否则SSH登录服务器，命令行不显示用户名和目录 
usermod -d / -s /bin/bash $SSH_USER

echo "=> Done!"
touch /.ssh_pw_set

echo "========================================================================"
echo "You can now connect to this Debian container via SSH using:"
echo ""
echo "    ssh -p <port> $SSH_USER@<host>"
echo "and enter the $SSH_USER password '$PASS' when prompted"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "========================================================================"
