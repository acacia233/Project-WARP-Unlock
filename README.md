### Project-WARP-Unlock

#### Intro

旨在借由Cloudflare WARP一键解锁大部分流媒体的脚本

工作原理：

- 安装ipset+dnsmasq+wireguard
- 禁用wireguard的自动路由
- 将vps的解析交由dnsmasq处理，为了将解析结果自动放入ipset
- 使用iptables为ipset中的ip打上mark，再让这些ip走特定的路由表
- 特定的路由表中仅存在一条使用wireguard的默认路由

**因为WireGuard直接安装对内核版本有一定的要求（>5.6）,所以该一键脚本不能在较老的系统/使用较老系统内核上正常使用**

*另有使用BoringTun实现的版本，用户态实现的WireGuard不依赖于内核版本。适配性更好

使用WireGuard的版本（需要内核版本 > 5.6）：`curl -sL https://raw.githubusercontent.com/acacia233/Project-WARP-Unlock/main/run.sh | bash`

使用BoringTun的版本：`curl -sL https://raw.githubusercontent.com/acacia233/Project-WARP-Unlock/main/run-boringtun.sh | bash`

如果遇到解决不了的问题，欢迎加入Telegram频道：@cutenicobest 探讨

依赖并不多，所以并无卸载脚本提供，`systemctl disable wg-quick@wg --now` 然后重启即可



#### 后话

- 能力强的可以根据脚本内容自行改动，该方法适用性强，可应用于其他的VPN应用分流

- WireGuard因为需要适配太多数情况，所以iptables规则清除较为暴力。如果原本配有iptables规则的建议自行修改部分清除规则，以达到最佳效果





