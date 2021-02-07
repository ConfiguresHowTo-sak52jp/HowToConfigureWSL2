#!/bin/bash

#-- IPアドレスは動的に変わるので起動時に取得する --
ownip=$(ifconfig eth0 | grep 'inet ' | awk '{print $2}')

set -e

#-- カレントのポート転送設定を削除 --
# sshd
cmd='/mnt/c/Windows/System32/netsh.exe interface portproxy delete v4tov4 listenport=22'
echo "$cmd";eval $cmd || echo IGNORE
# rsyslogd
cmd='/mnt/c/Windows/System32/netsh.exe interface portproxy delete v4tov4 listenport=514'
echo "$cmd";eval $cmd || echo IGNORE
# samba
cmd='/mnt/c/Windows/System32/netsh.exe interface portproxy delete v4tov4 listenport=137'
echo "$cmd";eval $cmd || echo IGNORE
cmd='/mnt/c/Windows/System32/netsh.exe interface portproxy delete v4tov4 listenport=138'
echo "$cmd";eval $cmd || echo IGNORE
cmd='/mnt/c/Windows/System32/netsh.exe interface portproxy delete v4tov4 listenport=139'
echo "$cmd";eval $cmd || echo IGNORE
cmd='/mnt/c/Windows/System32/netsh.exe interface portproxy delete v4tov4 listenport=445'
echo "$cmd";eval $cmd || echo IGNORE

#-- 各デーモンの停止 --
cmd="service rsyslog stop"
echo "$cmd";eval $cmd
cmd="service ssh stop"
echo "$cmd";eval $cmd
cmd="service smbd stop"
echo "$cmd";eval $cmd
