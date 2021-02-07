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

#-- 新しいポート転送設定を作成 --
# sshd
cmd="/mnt/c/Windows/System32/netsh.exe interface portproxy add v4tov4 listenport=22 connectaddress=$ownip"
echo "$cmd";eval $cmd
# rsyslogd
cmd="/mnt/c/Windows/System32/netsh.exe interface portproxy add v4tov4 listenport=514 connectaddress=$ownip"
echo "$cmd";eval $cmd
# samba
cmd="/mnt/c/Windows/System32/netsh.exe interface portproxy add v4tov4 listenport=137 connectaddress=$ownip"
echo "$cmd";eval $cmd
cmd="/mnt/c/Windows/System32/netsh.exe interface portproxy add v4tov4 listenport=138 connectaddress=$ownip"
echo "$cmd";eval $cmd
cmd="/mnt/c/Windows/System32/netsh.exe interface portproxy add v4tov4 listenport=139 connectaddress=$ownip"
echo "$cmd";eval $cmd
cmd="/mnt/c/Windows/System32/netsh.exe interface portproxy add v4tov4 listenport=445 connectaddress=$ownip"
echo "$cmd";eval $cmd

#-- IP helperサービスを起動 --
cmd="/mnt/c/Windows/System32/sc.exe config iphlpsvc start=auto"
echo "$cmd";eval $cmd || echo IGNORE
cmd="/mnt/c/Windows/System32/sc.exe start  iphlpsvc"
echo "$cmd";eval $cmd || echo IGNORE

#-- 各デーモンの起動 --
cmd="service rsyslog start"
echo "$cmd";eval $cmd
cmd="service ssh start"
echo "$cmd";eval $cmd
cmd="service smbd start"
echo "$cmd";eval $cmd
