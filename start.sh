#!/bin/bash
export LC_ALL=C
export LANG=en_US
export LANGUAGE=en_US.UTF-8

branch="master"

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
  sudoCmd="sudo"
else
  sudoCmd=""
fi

#copied & modified from atrandys trojan scripts
#copy from 秋水逸冰 ss scripts
if [[ -f /etc/redhat-release ]]; then
  release="centos"
  systemPackage="yum"
  #colorEcho ${RED} "unsupported OS"
  #exit 0
elif cat /etc/issue | grep -Eqi "debian"; then
  release="debian"
  systemPackage="apt-get"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
  release="ubuntu"
  systemPackage="apt-get"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
  release="centos"
  systemPackage="yum"
  #colorEcho ${RED} "unsupported OS"
  #exit 0
elif cat /proc/version | grep -Eqi "debian"; then
  release="debian"
  systemPackage="apt-get"
elif cat /proc/version | grep -Eqi "ubuntu"; then
  release="ubuntu"
  systemPackage="apt-get"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
  release="centos"
  systemPackage="yum"
  #colorEcho ${RED} "unsupported OS"
  #exit 0
fi

# install requirements
${sudoCmd} ${systemPackage} update
${sudoCmd} ${systemPackage} install software-properties-common -y -q
${sudoCmd} add-apt-repository ppa:ondrej/nginx-mainline -y
${sudoCmd} ${systemPackage} update
${sudoCmd} ${systemPackage} install wget coreutils nginx-extras unzip -y -q

# set time syncronise service
${sudoCmd} timedatectl set-ntp true

${sudoCmd} wget -q -N https://raw.githubusercontent.com/phlinhng/vless-nginx/${branch}/vless.sh -O ~/vless.sh