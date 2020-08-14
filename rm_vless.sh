
#!/bin/bash
export LC_ALL=C
export LANG=C
export LANGUAGE=en_US.UTF-8

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
elif cat /etc/issue | grep -Eqi "debian"; then
  release="debian"
  systemPackage="apt-get"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
  release="ubuntu"
  systemPackage="apt-get"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
  release="centos"
  systemPackage="yum"
elif cat /proc/version | grep -Eqi "debian"; then
  release="debian"
  systemPackage="apt-get"
elif cat /proc/version | grep -Eqi "ubuntu"; then
  release="ubuntu"
  systemPackage="apt-get"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
  release="centos"
  systemPackage="yum"
fi

# copied from v2ray official script
# colour code
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message
# colour function
colorEcho() {
  echo -e "\033[${1}${@:2}\033[0m" 1>& 2
}

colorEcho ${BLUE} "Shutting down v2ray service."
${sudoCmd} systemctl stop v2ray
${sudoCmd} systemctl disable caddy
${sudoCmd} rm -f /etc/systemd/system/v2ray.service
${sudoCmd} rm -f /etc/systemd/system/v2ray.service
${sudoCmd} rm -f /etc/systemd/system/v2ray@.service
${sudoCmd} rm -f /etc/systemd/system/v2ray@.service
colorEcho ${BLUE} "Removing v2ray files."
${sudoCmd} rm -rf /etc/v2ray
${sudoCmd} rm -rf /usr/local/bin/v2ray
${sudoCmd} rm -rf /usr/local/bin/v2ctl
${sudoCmd} rm -rf /usr/local/etc/v2ray
${sudoCmd} rm -rf /usr/local/lib/v2ray
${sudoCmd} rm -rf /var/log/v2ray

colorEcho ${BLUE} "Removing v2ray crontab"
${sudoCmd} crontab -l | grep -v 'v2ray/geoip.dat' | ${sudoCmd} crontab -
${sudoCmd} crontab -l | grep -v 'v2ray/geosite.dat' | ${sudoCmd} crontab -
colorEcho ${GREEN} "Removed v2ray successfully."

colorEcho ${BLUE} "Removing dummy site."
${sudoCmd} rm -rf /var/www/html

${sudoCmd} ${systemPackage} remove nginx -y
${sudoCmd} ${systemPackage} autoremove -y

${sudoCmd} rm -f ~/vless.sh

colorEcho ${BLUE} "卸载完成"