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

# VLESS 与 VMess 的区别
1. VMess 为了确保裸连时仍能有效保障安全性和隱蔽性，设计有很多加密运算。在裸连时，那些加密运算能保障传输安全性；然而在 TLS 隧道中，传输层安全由 TLS 保障，此时 Vmess 的加密计算显得冗余且耗费资源。
2. VLESS 減化了 Vmess 内部的加密机制，以減少计算量以达成降低延迟、提高吞吐量、节约计算成本（例如行动装置耗电量）的效果。
3. 由于 VLESS 的加密性不如 Vmess，其安全性强依赖 TLS，不建议在不可信通道中单独使用（也就是裸奔）VLESS。
4. 更多协议细节可参考 [@v2ray/discussion#768](https://github.com/v2ray/discussion/issues/768)

# 注意事项
1. 不支持 CDN
2. 若阁下先前使用过其他的脚本或方式安装过任何形式的代理，请先卸载先前的安装再使用本脚本
3. 太古老的系统模版可能不相容于新版 V2Ray 和 Nginx，推荐使用 Debian 10 / Ubuntu 18.04 以上系统
4. VLESS 适配期间，此脚本可能变动频繁，不建议用于生产环境
