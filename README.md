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