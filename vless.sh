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

# copied from v2ray official script
# colour code
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message
# colour function
colorEcho(){
  echo -e "\033[${1}${@:2}\033[0m" 1>& 2
}

red="\033[0;${RED}"
green="\033[0;${GREEN}"
nocolor="\033[0m"

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

VERSION="0.1"

continue_prompt() {
  read -rp "继续其他操作 (yes/no)? " choice
  case "${choice}" in
    [yY]|[yY][eE][sS] ) return 0 ;;
    * ) exit 0;;
  esac
}

checkIP() {
  local realIP="$(curl -s `curl -s https://raw.githubusercontent.com/phlinhng/v2ray-tcp-tls-web/master/custom/ip_api`)"
  local resolvedIP="$(ping $1 -c 1 | head -n 1 | grep  -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)"

  if [[ "${realIP}" == "${resolvedIP}" ]]; then
    return 0
  else
    return 1
  fi
}

get_v2ray() {
  curl -sL https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh | ${sudoCmd} bash
}

set_vless() {
  ${sudoCmd} cat > /usr/local/etc/v2ray/05_inbounds.json <<-EOF
{
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$1"
          }
        ],
        "decryption": "none",
        "fallback": {
          "port": 80
        }
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "alpn": [ "http/1.1" ],
          "certificates": [
            {
              "certificateFile": "/etc/ssl/v2ray/fullchain.pem",
              "keyFile": "/etc/ssl/v2ray/key.pem"
            }
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [ "http", "tls" ]
      }
    }
  ]
}
EOF
  wget -q https://raw.githubusercontent.com/phlinhng/vless-nginx/${branch}/config/03_routing.json -O /usr/local/etc/v2ray/03_routing.json
  wget -q https://raw.githubusercontent.com/phlinhng/vless-nginx/${branch}/config/06_outbounds.json -O /usr/local/etc/v2ray/06_outbounds.json
}

build_web() {
  if [ ! -f "/var/www/html/index.html" ]; then
    # choose and copy a random  template for dummy web pages
    local template="$(curl -s https://raw.githubusercontent.com/phlinhng/web-templates/master/list.txt | shuf -n  1)"
    wget -q https://raw.githubusercontent.com/phlinhng/web-templates/master/${template} -O /tmp/template.zip
    ${sudoCmd} mkdir -p /var/www/html
    ${sudoCmd} unzip -q /tmp/template.zip -d /var/www/html
    ${sudoCmd} wget -q https://raw.githubusercontent.com/phlinhng/v2ray-tcp-tls-web/${branch}/custom/robots.txt -O /var/www/html/robots.txt
  else
    echo "Dummy website existed. Skip building."
  fi
}

set_nginx() {
  ${sudoCmd} cat > /etc/nginx/sites-enabled/vless_fallback.conf <<-EOF
  server {
      listen 127.0.0.1:80;
      server_name $1;
      root /var/www/html;
      index index.php index.html index.htm;
  }
  server {
      listen 0.0.0.0:80;
      listen [::]:80;
      server_name $1;
      return 301 https://\$host\$request_uri;
  }
EOF
}

install_vless() {
  while true; do
    read -rp "解析到本 VPS 的域名: " V2_DOMAIN
    if checkIP "${V2_DOMAIN}"; then
      colorEcho ${GREEN} "域名 ${V2_DOMAIN} 解析正确, 即将开始安装"
      break
    else
      colorEcho ${RED} "域名 ${V2_DOMAIN} 解析有误 (yes: 强制继续, no: 重新输入, quit: 离开)"
      read -rp "若您确定域名解析正确, 可以继续进行安装作业. 强制继续? (yes/no/quit) " forceConfirm
      case "${forceConfirm}" in
        [yY]|[yY][eE][sS] ) break ;;
        [qQ]|[qQ][uU][iI][tT] ) return 0 ;;
      esac
    fi
  done

  # install v2ray-core
  get_v2ray

  # configurate vless
  colorEcho ${BLUE} "Setting VLESS"
  local uuid_vless="$(cat '/proc/sys/kernel/random/uuid')"
  set_vless "${uuid_vless}"

  # fetch geoip.dat and geosite.dat
  ${sudoCmd} mkdir -p /usr/local/lib/v2ray
  ${sudoCmd} wget -q https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat -O /usr/local/lib/v2ray/geoip.dat
  ${sudoCmd} wget -q https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat -O /usr/local/lib/v2ray/geosite.dat

  # set crontab to auto update geoip.dat and geosite.dat
  (crontab -l 2>/dev/null; echo "0 7 * * * wget -q https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat -O /usr/local/lib/v2ray/geoip.dat >/dev/null >/dev/null") | ${sudoCmd} crontab -
  (crontab -l 2>/dev/null; echo "0 7 * * * wget -q https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat -O /usr/local/lib/v2ray/geosite.dat >/dev/null >/dev/null") | ${sudoCmd} crontab -

  ${sudoCmd} mkdir -p /etc/ssl/v2ray

  # building dummy website
  colorEcho ${BLUE} "Building dummy web site"
  build_web

  # temporary config for issuing certs
  ${sudoCmd} cat > /etc/nginx/sites-enabled/vless_fallback.conf <<-EOF
  server {
      listen 80;
      server_name ${V2_DOMAIN};
      root /var/www/html;
      index index.php index.html index.htm;
  }
EOF

  ${sudoCmd} systemctl restart nginx

  # get acme.sh
  colorEcho ${BLUE} "Installing acme.sh"
  curl -fsSL https://get.acme.sh | ${sudoCmd} sh

  # issue certificate
  # get certificate before restarting nginx to avoid failure while issuing
  colorEcho ${BLUE} "Issuing certificate"
  ${sudoCmd} /root/.acme.sh/acme.sh --issue --nginx -d "${V2_DOMAIN}" --keylength ec-256

  # install certificate
  colorEcho ${BLUE} "Installing certificate"
  ${sudoCmd} /root/.acme.sh/acme.sh --install-cert --ecc -d "${V2_DOMAIN}" \
  --key-file /etc/ssl/v2ray/key.pem --fullchain-file /etc/ssl/v2ray/fullchain.pem \
  --reloadcmd "chmod 666 /etc/ssl/v2ray/fullchain.pem; chmod 666 /etc/ssl/v2ray/key.pem; systemctl restart v2ray"

  # configurate nginx for fallback
  set_nginx "${V2_DOMAIN}"

  colorEcho ${BLUE} "Activating services"
  ${sudoCmd} systemctl daemon-reload
  ${sudoCmd} systemctl reset-failed
  ${sudoCmd} systemctl enable v2ray
  ${sudoCmd} systemctl restart v2ray 2>/dev/null ## restart v2ray to enable new config
  ${sudoCmd} systemctl enable nginx
  ${sudoCmd} systemctl restart nginx

  colorEcho ${GREEN} "安装 VLESS+NGINX 成功!"

  echo ""
  echo "${V2_DOMAIN}:443"
  echo "${uuid_vless}" && echo ""
}

get_cert() {
  while true; do
    read -rp "解析到本 VPS 的域名: " V2_DOMAIN
    if checkIP "${V2_DOMAIN}"; then
      colorEcho ${GREEN} "域名 ${V2_DOMAIN} 解析正确, 即将开始安装"
      break
    else
      colorEcho ${RED} "域名 ${V2_DOMAIN} 解析有误 (yes: 强制继续, no: 重新输入, quit: 离开)"
      read -rp "若您确定域名解析正确, 可以继续进行安装作业. 强制继续? (yes/no/quit) " forceConfirm
      case "${forceConfirm}" in
        [yY]|[yY][eE][sS] ) break ;;
        [qQ]|[qQ][uU][iI][tT] ) return 0 ;;
      esac
    fi
  done

  colorEcho ${BLUE} "Issuing certificate"
  ${sudoCmd} /root/.acme.sh/acme.sh --issue --nginx -d "${V2_DOMAIN}" --keylength ec-256

  # install certificate
  colorEcho ${BLUE} "Installing certificate"
  ${sudoCmd} /root/.acme.sh/acme.sh --install-cert --ecc -d "${V2_DOMAIN}" \
  --key-file /etc/ssl/v2ray/key.pem --fullchain-file /etc/ssl/v2ray/fullchain.pem \
  --reloadcmd "chmod 666 /etc/ssl/v2ray/fullchain.pem; chmod 666 /etc/ssl/v2ray/key.pem; systemctl restart v2ray"

  ${sudoCmd} systemctl daemon-reload
  ${sudoCmd} systemctl reset-failed
  ${sudoCmd} systemctl enable v2ray
  ${sudoCmd} systemctl restart v2ray 2>/dev/null ## restart v2ray to enable new config

  colorEcho ${GREEN} "更新证书成功!"
}

vps_tools() {
  ${sudoCmd} ${systemPackage} install wget -y -qq
  wget -q https://raw.githubusercontent.com/phlinhng/v2ray-tcp-tls-web/${branch}/tools/vps_tools.sh -O /tmp/vps_tools.sh && chmod +x /tmp/vps_tools.sh && ${sudoCmd} /tmp/vps_tools.sh
  exit 0
}

rm_vless() {
  ${sudoCmd} ${systemPackage} install curl -y -qq
  curl -sL https://raw.githubusercontent.com/phlinhng/vless-nginx/${branch}/rm_vless.sh | bash
  exit 0
}

show_menu() {
  echo ""
  echo "----------基础操作----------"
  echo "0) 安装 VLESS+NGINX"
  echo "1) 更新 v2ray-core"
  echo "----------管理工具----------"
  echo "2) 修复证书/更换域名"
  echo "3) VPS 工具"
  echo "4) 卸载脚本"
  echo ""
}

menu() {
  colorEcho ${YELLOW} "VLESS automated script v${VERSION}"
  colorEcho ${YELLOW} "author: phlinhng"

  #check_status

  COLUMNS=woof

  while true; do
    show_menu
    read -rp "选择操作 [输入任意值退出]: " opt
    case "${opt}" in
      "0") install_vless && continue_prompt ;;
      "1") get_v2ray && continue_prompt ;;
      "2") get_cert && continue_prompt ;;
      "3") vps_tools ;;
      "4") rm_vless ;;
      *) break ;;
    esac
  done

}

menu