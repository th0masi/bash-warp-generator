#!/bin/bash

clear
mkdir -p ~/.cloudshell && touch ~/.cloudshell/no-apt-get-warning
echo "Установка зависимостей..."
sudo apt-get update -y --fix-missing && sudo apt-get install wireguard-tools jq -y --fix-missing

priv="${1:-$(wg genkey)}"
pub="${2:-$(echo "${priv}" | wg pubkey)}"
api="https://api.cloudflareclient.com/v0i1909051800"
ins() { curl -s -H 'user-agent:' -H 'content-type: application/json' -X "$1" "${api}/$2" "${@:3}"; }
sec() { ins "$1" "$2" -H "authorization: Bearer $3" "${@:4}"; }
response=$(ins POST "reg" -d "{\"install_id\":\"\",\"tos\":\"$(date -u +%FT%T.000Z)\",\"key\":\"${pub}\",\"fcm_token\":\"\",\"type\":\"ios\",\"locale\":\"en_US\"}")

id=$(echo "$response" | jq -r '.result.id')
token=$(echo "$response" | jq -r '.result.token')
response=$(sec PATCH "reg/${id}" "$token" -d '{"warp_enabled":true}')
peer_pub=$(echo "$response" | jq -r '.result.config.peers[0].public_key')
peer_endpoint=$(echo "$response" | jq -r '.result.config.peers[0].endpoint.host')
client_ipv4=$(echo "$response" | jq -r '.result.config.interface.addresses.v4')
client_ipv6=$(echo "$response" | jq -r '.result.config.interface.addresses.v6')
port=$(echo "$peer_endpoint" | sed 's/.*:\([0-9]*\)$/\1/')
peer_endpoint=$(echo "$peer_endpoint" | sed 's/\(.*\):[0-9]*/162.159.193.5/')

conf=$(cat <<-EOM
[Interface]
PrivateKey = ${priv}
S1 = 0
S2 = 0
Jc = 120
Jmin = 23
Jmax = 911
H1 = 1
H2 = 2
H3 = 3
H4 = 4
Address = ${client_ipv4}, ${client_ipv6}
DNS = 1.1.1.1, 2606:4700:4700::1111, 1.0.0.1, 2606:4700:4700::1001

[Peer]
PublicKey = ${peer_pub}
AllowedIPs = 0.0.0.0/2, 64.0.0.0/5, 72.0.0.0/7, 74.0.0.0/10, 74.64.0.0/11, 74.96.0.0/12, 74.112.0.0/13, 74.120.0.0/14, 74.124.0.0/16, 74.125.0.0/17, 74.125.128.0/21, 74.125.136.0/22, 74.125.140.0/23, 74.125.142.0/24, 74.125.143.0/25, 74.125.143.128/26, 74.125.143.192/30, 74.125.143.196/31, 74.125.143.199/32, 74.125.143.200/29, 74.125.143.208/28, 74.125.143.224/27, 74.125.144.0/20, 74.125.160.0/19, 74.125.192.0/18, 74.126.0.0/15, 74.128.0.0/9, 75.0.0.0/8, 76.0.0.0/6, 80.0.0.0/10, 80.64.0.0/15, 80.66.0.0/18, 80.66.64.0/20, 80.66.80.0/23, 80.66.82.0/27, 80.66.82.32/29, 80.66.82.40/30, 80.66.82.44/32, 80.66.82.46/31, 80.66.82.48/28, 80.66.82.64/26, 80.66.82.128/25, 80.66.83.0/24, 80.66.84.0/22, 80.66.88.0/21, 80.66.96.0/19, 80.66.128.0/17, 80.67.0.0/16, 80.68.0.0/14, 80.72.0.0/13, 80.80.0.0/12, 80.96.0.0/11, 80.128.0.0/9, 81.0.0.0/8, 82.0.0.0/7, 84.0.0.0/6, 88.0.0.0/6, 92.0.0.0/10, 92.64.0.0/11, 92.96.0.0/12, 92.112.0.0/13, 92.120.0.0/15, 92.122.0.0/18, 92.122.64.0/23, 92.122.66.0/24, 92.122.67.0/27, 92.122.67.32/31, 92.122.67.35/32, 92.122.67.36/30, 92.122.67.40/29, 92.122.67.48/28, 92.122.67.64/26, 92.122.67.128/25, 92.122.68.0/22, 92.122.72.0/21, 92.122.80.0/20, 92.122.96.0/19, 92.122.128.0/17, 92.123.0.0/16, 92.124.0.0/14, 92.128.0.0/9, 93.0.0.0/8, 94.0.0.0/8, 95.0.0.0/9, 95.128.0.0/13, 95.136.0.0/14, 95.140.0.0/17, 95.140.128.0/18, 95.140.192.0/19, 95.140.224.0/22, 95.140.228.0/27, 95.140.228.33/32, 95.140.228.34/31, 95.140.228.36/30, 95.140.228.40/29, 95.140.228.48/28, 95.140.228.64/26, 95.140.228.128/25, 95.140.229.0/24, 95.140.230.0/23, 95.140.232.0/21, 95.140.240.0/20, 95.141.0.0/16, 95.142.0.0/15, 95.144.0.0/12, 95.160.0.0/11, 95.192.0.0/10, 96.0.0.0/5, 104.0.0.0/12, 104.16.0.0/18, 104.16.64.0/21, 104.16.72.0/22, 104.16.76.0/23, 104.16.78.0/24, 104.16.79.0/26, 104.16.79.64/29, 104.16.79.72/32, 104.16.79.74/31, 104.16.79.76/30, 104.16.79.80/28, 104.16.79.96/27, 104.16.79.128/25, 104.16.80.0/20, 104.16.96.0/19, 104.16.128.0/17, 104.17.0.0/16, 104.18.0.0/15, 104.20.0.0/14, 104.24.0.0/13, 104.32.0.0/11, 104.64.0.0/10, 104.128.0.0/10, 104.192.0.0/11, 104.224.0.0/12, 104.240.0.0/13, 104.248.0.0/14, 104.252.0.0/15, 104.254.0.0/16, 104.255.0.0/18, 104.255.64.0/19, 104.255.96.0/21, 104.255.104.0/24, 104.255.105.0/27, 104.255.105.32/28, 104.255.105.48/30, 104.255.105.52/32, 104.255.105.55/32, 104.255.105.56/29, 104.255.105.64/26, 104.255.105.128/25, 104.255.106.0/23, 104.255.108.0/22, 104.255.112.0/20, 104.255.128.0/17, 105.0.0.0/8, 106.0.0.0/7, 108.0.0.0/9, 108.128.0.0/11, 108.160.0.0/12, 108.176.0.0/16, 108.177.0.0/21, 108.177.8.0/22, 108.177.12.0/23, 108.177.14.0/26, 108.177.14.64/28, 108.177.14.80/29, 108.177.14.88/30, 108.177.14.92/31, 108.177.14.95/32, 108.177.14.96/27, 108.177.14.128/25, 108.177.15.0/24, 108.177.16.0/20, 108.177.32.0/19, 108.177.64.0/18, 108.177.128.0/17, 108.178.0.0/15, 108.180.0.0/14, 108.184.0.0/13, 108.192.0.0/10, 109.0.0.0/8, 110.0.0.0/7, 112.0.0.0/4, 128.0.0.0/3, 160.0.0.0/4, 176.0.0.0/5, 184.0.0.0/6, 188.0.0.0/10, 188.64.0.0/11, 188.96.0.0/12, 188.112.0.0/15, 188.114.0.0/18, 188.114.64.0/19, 188.114.96.0/23, 188.114.98.0/25, 188.114.98.128/26, 188.114.98.192/27, 188.114.98.225/32, 188.114.98.226/31, 188.114.98.228/30, 188.114.98.232/29, 188.114.98.240/28, 188.114.99.0/25, 188.114.99.128/26, 188.114.99.192/27, 188.114.99.225/32, 188.114.99.226/31, 188.114.99.228/30, 188.114.99.232/29, 188.114.99.240/28, 188.114.100.0/22, 188.114.104.0/21, 188.114.112.0/20, 188.114.128.0/17, 188.115.0.0/16, 188.116.0.0/14, 188.120.0.0/13, 188.128.0.0/9, 189.0.0.0/8, 190.0.0.0/7, 192.0.0.0/2, ::/3, 2000::/6, 2400::/7, 2600::/14, 2604::/15, 2606::/18, 2606:4000::/22, 2606:4400::/23, 2606:4600::/24, 2606:4700:0:1::/64, 2606:4700:0:2::/63, 2606:4700:0:4::/62, 2606:4700:0:8::/61, 2606:4700:0:10::/60, 2606:4700:0:20::/59, 2606:4700:0:40::/58, 2606:4700:0:80::/57, 2606:4700:0:100::/56, 2606:4700:0:200::/55, 2606:4700:0:400::/54, 2606:4700:0:800::/53, 2606:4700:0:1000::/52, 2606:4700:0:2000::/51, 2606:4700:0:4000::/50, 2606:4700:0:8000::/49, 2606:4700:1::/48, 2606:4700:2::/47, 2606:4700:4::/46, 2606:4700:8::/45, 2606:4700:10::/44, 2606:4700:20::/43, 2606:4700:40::/42, 2606:4700:80::/41, 2606:4700:100::/40, 2606:4700:200::/39, 2606:4700:400::/38, 2606:4700:800::/37, 2606:4700:1000::/36, 2606:4700:2000::/35, 2606:4700:4000::/34, 2606:4700:8000::/33, 2606:4701::/32, 2606:4702::/31, 2606:4704::/30, 2606:4708::/29, 2606:4710::/28, 2606:4720::/27, 2606:4740::/26, 2606:4780::/25, 2606:4800::/21, 2606:5000::/20, 2606:6000::/19, 2606:8000::/17, 2607::/16, 2608::/13, 2610::/12, 2620::/11, 2640::/10, 2680::/9, 2700::/8, 2800::/7, 2a00::/20, 2a00:1000::/22, 2a00:1400::/26, 2a00:1440::/28, 2a00:1450::/34, 2a00:1450:4000::/44, 2a00:1450:4010::/53, 2a00:1450:4010:800::/54, 2a00:1450:4010:c00::/64, 2a00:1450:4010:c02::/63, 2a00:1450:4010:c04::/62, 2a00:1450:4010:c08::/62, 2a00:1450:4010:c0c::/63, 2a00:1450:4010:c0f::/64, 2a00:1450:4010:c10::/60, 2a00:1450:4010:c20::/59, 2a00:1450:4010:c40::/58, 2a00:1450:4010:c80::/57, 2a00:1450:4010:d00::/56, 2a00:1450:4010:e00::/55, 2a00:1450:4010:1000::/52, 2a00:1450:4010:2000::/51, 2a00:1450:4010:4000::/50, 2a00:1450:4010:8000::/49, 2a00:1450:4011::/48, 2a00:1450:4012::/47, 2a00:1450:4014::/46, 2a00:1450:4018::/45, 2a00:1450:4020::/43, 2a00:1450:4040::/42, 2a00:1450:4080::/41, 2a00:1450:4100::/40, 2a00:1450:4200::/39, 2a00:1450:4400::/38, 2a00:1450:4800::/37, 2a00:1450:5000::/36, 2a00:1450:6000::/35, 2a00:1450:8000::/33, 2a00:1451::/32, 2a00:1452::/31, 2a00:1454::/30, 2a00:1458::/29, 2a00:1460::/27, 2a00:1480::/25, 2a00:1500::/24, 2a00:1600::/23, 2a00:1800::/21, 2a00:2000::/19, 2a00:4000::/18, 2a00:8000::/17, 2a01::/16, 2a02::/15, 2a04::/15, 2a06::/17, 2a06:8000::/20, 2a06:9000::/21, 2a06:9800::/25, 2a06:9880::/26, 2a06:98c0::/32, 2a06:98c1::/35, 2a06:98c1:2000::/36, 2a06:98c1:3000::/40, 2a06:98c1:3100::/43, 2a06:98c1:3120::/47, 2a06:98c1:3122::/48, 2a06:98c1:3123::/49, 2a06:98c1:3123:8000::/50, 2a06:98c1:3123:c000::/51, 2a06:98c1:3123:e001::/64, 2a06:98c1:3123:e002::/63, 2a06:98c1:3123:e004::/62, 2a06:98c1:3123:e008::/61, 2a06:98c1:3123:e010::/60, 2a06:98c1:3123:e020::/59, 2a06:98c1:3123:e040::/58, 2a06:98c1:3123:e080::/57, 2a06:98c1:3123:e100::/56, 2a06:98c1:3123:e200::/55, 2a06:98c1:3123:e400::/54, 2a06:98c1:3123:e800::/53, 2a06:98c1:3123:f000::/52, 2a06:98c1:3124::/46, 2a06:98c1:3128::/45, 2a06:98c1:3130::/44, 2a06:98c1:3140::/42, 2a06:98c1:3180::/41, 2a06:98c1:3200::/39, 2a06:98c1:3400::/38, 2a06:98c1:3800::/37, 2a06:98c1:4000::/34, 2a06:98c1:8000::/33, 2a06:98c2::/31, 2a06:98c4::/30, 2a06:98c8::/29, 2a06:98d0::/28, 2a06:98e0::/27, 2a06:9900::/24, 2a06:9a00::/23, 2a06:9c00::/22, 2a06:a000::/19, 2a06:c000::/18, 2a07::/16, 2a08::/13, 2a10::/12, 2a20::/11, 2a40::/10, 2a80::/9, 2b00::/8, 2c00::/6, 3000::/4, 4000::/2, 8000::/1
Endpoint = ${peer_endpoint}:${port}
EOM
)

clear
config_file="WARP.conf"
echo "${conf}" > "${config_file}"

cloudshell download "${config_file}"

clear

echo "Скачать конфиг можно через встроенную команду Cloud Shell."


