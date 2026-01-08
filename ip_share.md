nano /etc/network/interfaces
for vmbr1 setup remember to uodate ip
```
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback
iface lo inet6 loopback

# =========================
# Physical NIC
# =========================
auto eno1
iface eno1 inet manual

# =========================
# Public bridge (Main IP)
# =========================
auto vmbr0
iface vmbr0 inet static
        address 136.243.106.141/26
        gateway 136.243.106.129
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0

# =========================
# Additional IP (NO gateway)
# =========================
auto vmbr0:1
iface vmbr0:1 inet static
        address 136.243.106.138/32

# =========================
# Private NAT bridge for VMs
# =========================
auto vmbr1
iface vmbr1 inet static
        address 10.10.10.1/24
        bridge-ports none
        bridge-stp off
        bridge-fd 0

```

```
ifreload -a
```

```
iptables -F
iptables -t nat -F
```

```
# enable forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# SNAT (internet via additional IP)
iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -j SNAT --to-source 136.243.106.138

# forward allow
iptables -A FORWARD -s 10.10.10.0/24 -j ACCEPT
iptables -A FORWARD -d 10.10.10.0/24 -j ACCEPT
```

vm ip add ssh
```
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 222 -j DNAT --to 10.10.10.10:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 223 -j DNAT --to 10.10.10.11:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 224 -j DNAT --to 10.10.10.12:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 225 -j DNAT --to 10.10.10.13:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 226 -j DNAT --to 10.10.10.14:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 227 -j DNAT --to 10.10.10.15:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 228 -j DNAT --to 10.10.10.16:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 229 -j DNAT --to 10.10.10.17:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 230 -j DNAT --to 10.10.10.18:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 231 -j DNAT --to 10.10.10.19:22

iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 232 -j DNAT --to 10.10.10.20:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 233 -j DNAT --to 10.10.10.21:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 234 -j DNAT --to 10.10.10.22:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 235 -j DNAT --to 10.10.10.23:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 236 -j DNAT --to 10.10.10.24:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 237 -j DNAT --to 10.10.10.25:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 238 -j DNAT --to 10.10.10.26:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 239 -j DNAT --to 10.10.10.27:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 240 -j DNAT --to 10.10.10.28:22
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 241 -j DNAT --to 10.10.10.29:22
```

vm ip add rdp
```
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4389 -j DNAT --to 10.10.10.10:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4390 -j DNAT --to 10.10.10.11:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4391 -j DNAT --to 10.10.10.12:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4392 -j DNAT --to 10.10.10.13:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4393 -j DNAT --to 10.10.10.14:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4394 -j DNAT --to 10.10.10.15:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4395 -j DNAT --to 10.10.10.16:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4396 -j DNAT --to 10.10.10.17:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4397 -j DNAT --to 10.10.10.18:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4398 -j DNAT --to 10.10.10.19:3389

iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4399 -j DNAT --to 10.10.10.20:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4400 -j DNAT --to 10.10.10.21:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4401 -j DNAT --to 10.10.10.22:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4402 -j DNAT --to 10.10.10.23:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4403 -j DNAT --to 10.10.10.24:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4404 -j DNAT --to 10.10.10.25:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4405 -j DNAT --to 10.10.10.26:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4406 -j DNAT --to 10.10.10.27:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4407 -j DNAT --to 10.10.10.28:3389
iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4408 -j DNAT --to 10.10.10.29:3389
```
