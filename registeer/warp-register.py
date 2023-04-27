import base64
import datetime
import json
import random
import requests
import string
import subprocess
import sys


def check_wireguard_installed():
    try:
        subprocess.run(["wg"], capture_output=True)
    except FileNotFoundError:
        print("WireGuard not found. Please install WireGuard and try again.")
        sys.exit(1)


def genstring(k):
    return "".join(random.choices(string.ascii_lowercase + string.digits, k=k))


def genkey():
    return subprocess.run(["wg", "genkey"], capture_output=True).stdout.decode().strip()


def pubkey(privkey):
    return subprocess.run(["wg", "pubkey"], input=privkey.encode(), capture_output=True).stdout.decode().strip()


def reg(key):
    url = "https://api.cloudflareclient.com/v0a977/reg"
    headers = {
        "User-Agent": "okhttp/114.5.14",
        "Content-Type": "application/json; charset=UTF-8",
    }
    install_id = genstring(11)
    payload = {
        "key": key,
        "install_id": install_id,
        "fcm_token": f"{install_id}:APA91b{genstring(134)}",
        "referer": "1.1.1.1",
        "warp_enabled": True,
        "tos": datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S+08:00"),
        "model": "Huawei 13 Pro Max",
        "type": "Android",
        "locale": "en_US",
    }
    r = requests.post(url, headers=headers, data=json.dumps(payload))
    return r.json()


def register_warp_account():
    k = genkey()
    pk = pubkey(k)
    r = reg(pk)
    c = r['config']

    wg_config = generate_wg_config(r["config"], k)
    save_wg_config(wg_config)

    print("PrivateKey =", k)
    print("PublicKey =", c['peers'][0]['public_key'])
    print("IPv4 =", c['interface']['addresses']['v4'])
    print("IPv6 =", c['interface']['addresses']['v6'])
    print("RoutingID =", list(base64.b64decode(c['client_id'])))


def generate_wg_config(config, private_key):
    public_key = config['peers'][0]['public_key']
    allowed_ips = config['peers'][0].get('allowed_ips', ['0.0.0.0/0', '::/0'])  # Use the get method with a default value
    endpoint_host = config['peers'][0]['endpoint']['host']
    endpoint_port = config['peers'][0]['endpoint'].get('port', 2408) 
    ipv4_address = config['interface']['addresses']['v4']
    ipv6_address = config['interface']['addresses']['v6']
    routing_id = ', '.join([str(x) for x in list(base64.b64decode(config['client_id']))])

    wg_config = f"""[Interface]
PrivateKey = {private_key}
Address = {ipv4_address}, {ipv6_address}
DNS = 1.1.1.1
MTU = 1400
Table = off

[Peer]
PublicKey = {public_key}
AllowedIPs = {', '.join(allowed_ips)}
Endpoint = {endpoint_host}:{endpoint_port}
#RoutingID = [{routing_id}]
"""
    return wg_config

def save_wg_config(wg_config, file_path="/etc/wireguard/wgcf.conf"):
    with open(file_path, "w") as f:
        f.write(wg_config)


def main():
    check_wireguard_installed()
    register_warp_account()

if __name__ == "__main__":
    main()
