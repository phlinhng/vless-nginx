# VLESS NGINX 脚本
本脚本为示范性脚本，仅供体验 VLESS 使用。待 VLESS 稳定后会合并至 [v2ray-tcp-tls-web](https://github.com/phlinhng/v2ray-tcp-tls-web) 中。

# 使用说明
+ 初次使用
```sh
bash <(curl -sL https://raw.githubusercontent.com/phlinhng/vless-nginx/master/start.sh) && bash ~/vless.sh
```
+ 再次呼叫
```sh
bash ~/vless.sh
```

# 注意事项
1. 不支持 CDN
2. 若阁下先前使用过其他的脚本或方式安装过任何形式的代理，请先卸载先前的安装再使用本脚本
3. 太古老的系统模版可能不相容于新版 V2Ray 和 Nginx，推荐使用 Debian 10 / Ubuntu 18.04 以上系统
4. VLESS 适配期间，此脚本可能变动频繁，不建议用于生产环境
