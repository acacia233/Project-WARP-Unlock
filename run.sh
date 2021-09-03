#!/bin/bash

apt-get update > /dev/null
apt-get install -y ipset dnsmasq wireguard resolvconf > /dev/null
echo '250   warp' >>/etc/iproute2/rt_tables
wget -qO /etc/wireguard/wgcf https://github.com/ViRb3/wgcf/releases/download/v2.2.8/wgcf_2.2.8_linux_amd64
chmod +x /etc/wireguard/wgcf
/etc/wireguard/wgcf register --accept-tos --config /etc/wireguard/wgcf-account.toml
sleep 10
/etc/wireguard/wgcf generate --config /etc/wireguard/wgcf-account.toml --profile /etc/wireguard/wg.conf
sleep 10
sed -i "s/#conf-dir/conf-dir/g" /etc/dnsmasq.conf
wget -qO /etc/dnsmasq.d/warp.conf https://raw.githubusercontent.com/acacia233/Project-WARP-Unlock/main/dnsmasq/warp.conf
wget -qO /etc/wireguard/up https://raw.githubusercontent.com/acacia233/Project-WARP-Unlock/main/scripts/up
wget -qO /etc/wireguard/down https://raw.githubusercontent.com/acacia233/Project-WARP-Unlock/main/scripts/down
chmod +x /etc/wireguard/up
chmod +x /etc/wireguard/down
sed -i '7 i Table = off' /etc/wireguard/wg.conf
sed -i '8 i PostUp = /etc/wireguard/up' /etc/wireguard/wg.conf
sed -i '9 i Predown = /etc/wireguard/down' /etc/wireguard/wg.conf
sed -i "s/engage.cloudflareclient.com/162.159.192.3/g" /etc/wireguard/wg.conf
systemctl disable systemd-resolved --now
systemctl enable dnsmasq --now
systemctl enable wg-quick@wg --now
systemctl restart dnsmasq