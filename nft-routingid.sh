#!/bin/bash

# Usage - nft-routingid.sh "114,514,114"

input_routing_id="$1"

IFS=',' read -ra decimal_routing_id <<< "$input_routing_id"

routing_id=$(printf '%02x%02x%02x' "${decimal_routing_id[@]}")
routing_id=$((16#$routing_id))

nft_cmd=$(cat << EOF
add table inet wgcf
flush table inet wgcf
table inet wgcf{
  chain output{
    type filter hook output priority mangle; policy accept;
    ip6 daddr 2606:4700:d0::/48 udp dport {2408, 500, 4500, 1701} @th,72,24 set $routing_id counter ;
    ip daddr 162.159.193.0/24 udp dport {2408, 500, 4500, 1701} @th,72,24 set $routing_id counter ;
  }
  chain input{
    type filter hook input priority mangle; policy accept;
    ip6 saddr 2606:4700:d0::/48 udp sport {2408, 500, 4500, 1701} @th,72,24 set 0 counter;
    ip saddr 162.159.193.0/24 udp sport {2408, 500, 4500, 1701} @th,72,24 set 0 counter;
  }
}
EOF
)

echo "$nft_cmd" | nft -f -