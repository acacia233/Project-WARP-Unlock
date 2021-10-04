#!/bin/bash

# > System:Ubuntu 20

source /etc/profile

function Start {
    echo -e " [Intro] One-Click Unlock Stream Media Script By Cloudflare-WARP"
    echo -e " [Intro] Test System:Ubuntu 20"
    echo -e " [Intro] OpenSource-Project:https://github.com/acacia233/Project-WARP-Unlock"
    echo -e " [Intro] Telegram Channel:https://t.me/cutenicobest"
    echo -e " [Intro] Version:2021-09-08-1"
    Check_System_Depandencies
}

function Check_System_Depandencies {
    echo -e " [Info] Installing Depandencies..."
    apt-get update >/dev/null
    apt-get install -yq ipset dnsmasq wireguard resolvconf mtr >/dev/null 2>&1
    Download_Profile
    Generate_WireGuard_WARP_Profile
}

function Download_Profile {
    wget -qO /etc/dnsmasq.d/warp.conf https://raw.githubusercontent.com/acacia233/Project-WARP-Unlock/main/dnsmasq/warp.conf
    wget -qO /etc/wireguard/up https://raw.githubusercontent.com/acacia233/Project-WARP-Unlock/main/scripts/up
    wget -qO /etc/wireguard/down https://raw.githubusercontent.com/acacia233/Project-WARP-Unlock/main/scripts/down
    chmod +x /etc/wireguard/up
    chmod +x /etc/wireguard/down
}

function Generate_WireGuard_WARP_Profile {
    echo -e " [Info] Generating WARP Profile,Please Wait..."
    wget -qO /etc/wireguard/wgcf https://github.com/ViRb3/wgcf/releases/download/v2.2.8/wgcf_2.2.8_linux_amd64
    chmod +x /etc/wireguard/wgcf
    /etc/wireguard/wgcf register --accept-tos --config /etc/wireguard/wgcf-account.toml >/dev/null 2>&1
    sleep 10
    /etc/wireguard/wgcf generate --config /etc/wireguard/wgcf-account.toml --profile /etc/wireguard/wg.conf >/dev/null 2>&1
    sleep 10
    sed -i '7 i Table = off' /etc/wireguard/wg.conf
    sed -i '8 i PostUp = /etc/wireguard/up' /etc/wireguard/wg.conf
    sed -i '9 i Predown = /etc/wireguard/down' /etc/wireguard/wg.conf
    sed -i '15 i PersistentKeepalive = 5' /etc/wireguard/wg.conf
    sed -i "s/engage.cloudflareclient.com/162.159.192.3/g" /etc/wireguard/wg.conf
    Routing_WireGuard_WARP
}

function Routing_WireGuard_WARP {
    local rt_tables_status="$(cat /etc/iproute2/rt_tables | grep warp)"
    if [[ ! -n "$rt_tables_status" ]]; then
        echo '250   warp' >>/etc/iproute2/rt_tables
        echo -e " [Info] Creating Routing Table..."
    fi
    systemctl disable systemd-resolved --now >/dev/null 2>&1
    sleep 2
    systemctl enable dnsmasq --now >/dev/null 2>&1
    sleep 2
    systemctl enable wg-quick@wg --now >/dev/null 2>&1
    sleep 2
    systemctl restart dnsmasq >/dev/null 2>&1
    echo 'nameserver 127.0.0.1' > /etc/resolv.conf
    Check_finished
}

function Check_finished {
    local wireguard_status="$(ip link | grep wg)"
    if [[ "$wireguard_status" != *"wg"* ]]; then
        echo -e " [Error] WireGuard is not Running,Restarting..."
        systemctl restart wg-quick@wg
    else
        echo -e " [Info] WireGuard is Running,Check Connection..."
    fi
    local connection_status="$(ping 1.1.1.1 -I wg -c 1 2>&1)"
    if [[ "$connection_status" != *"unreachable"* ]] && [[ "$connection_status" != *"Unreachable"* ]] && [[ "$connection_status" != *"SO_BINDTODEVICE"* ]] && [[ "$connection_status" != *"100% packet loss"* ]]; then
        echo -e " [Info] Connection Established..."
    else
        echo -e " [Error] Connection Refused,Please check manually!"
        exit
    fi
    local routing_status="$(mtr -wn -c 1 youtube.com)"
    if [[ "$routing_status" != *"172.16.0.1"* ]]; then
        echo -e " [Error] Routing is not correct,Please check manually!"
    else
        echo -e " [Info] Routing is working normally,Enjoy~"
    fi
}

Start
