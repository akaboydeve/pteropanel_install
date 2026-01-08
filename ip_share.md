# IP sharing / NAT setup (Proxmox / Debian-style /etc/network/interfaces)

This file describes a clean, formatted set of steps and example commands to share a public additional IP with VMs behind a private NAT bridge. Adjust addresses and interface names to match your environment.

---

## 1) Edit network interfaces

Open `/etc/network/interfaces` (or the files under `/etc/network/interfaces.d/`) and configure the physical NIC, public bridge, additional IP (no gateway), and a private bridge for VMs:

```bash
sudo nano /etc/network/interfaces
```

Example content (replace `eno1`, addresses, and gateway as needed):

```
# include fragments
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

Notes:
- Update `vmbr1` address if you want a different private subnet.
- `vmbr0:1` is an alias for the additional public IP (no gateway on the alias).

---

## 2) Apply network changes

Reload interfaces (ifreload is provided by ifupdown2; otherwise use `systemctl restart networking` or reboot):

```bash
sudo ifreload -a
# or, if not available:
# sudo systemctl restart networking
```

---

## 3) Enable IP forwarding (temporarily + persistently)

Temporarily enable forwarding:

```bash
sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
```

Make it persistent across reboots by adding to `/etc/sysctl.conf` or a `/etc/sysctl.d/` file:

```bash
# add to /etc/sysctl.d/99-sysctl.conf
sudo tee /etc/sysctl.d/99-sysctl.conf > /dev/null <<'EOF'
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system
```

---

## 4) Flush existing iptables rules (optional, be careful on remote systems)

If you are sure, flush current rules first (this will drop any existing rules):

```bash
sudo iptables -F
sudo iptables -t nat -F
```

You may also want to flush filter chains policy defaults or save rules first.

---

## 5) Basic NAT/SNAT for outgoing traffic (VM internet access)

SNAT so VMs use the additional public IP for outbound connections:

```bash
# SNAT: VMs 10.10.10.0/24 appear as 136.243.106.138 on the internet
sudo iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -j SNAT --to-source 136.243.106.138
```

Allow forwarding between host and VMs:

```bash
sudo iptables -A FORWARD -s 10.10.10.0/24 -j ACCEPT
sudo iptables -A FORWARD -d 10.10.10.0/24 -j ACCEPT
```

(You can tighten these policies later to restrict protocols/ports.)

---

## 6) Port forwarding (PREROUTING DNAT) — SSH and RDP examples

If you want to map different public ports on the additional IP to different VM IPs/ports, use PREROUTING DNAT rules. Below are two approaches: explicit rules and a shell loop to generate many similar rules.

### Explicit examples (matching what you had)

SSH (public ports 222..241 → 10.10.10.10..10.10.10.29:22):

```bash
sudo iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 222 -j DNAT --to-destination 10.10.10.10:22
sudo iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 223 -j DNAT --to-destination 10.10.10.11:22
... (repeat for each mapping) ...
sudo iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 241 -j DNAT --to-destination 10.10.10.29:22
```

RDP (public ports 4389..4408 → 10.10.10.10..10.10.10.29:3389):

```bash
sudo iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4389 -j DNAT --to-destination 10.10.10.10:3389
sudo iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4390 -j DNAT --to-destination 10.10.10.11:3389
... (repeat for each mapping) ...
sudo iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport 4408 -j DNAT --to-destination 10.10.10.29:3389
```

### Generate rules with a shell loop (recommended for many sequential mappings)

SSH mapping loop:

```bash
for i in $(seq 0 19); do
  port=$((222 + i))
  vm_ip="10.10.10.$((10 + i))"
  sudo iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport "${port}" -j DNAT --to-destination "${vm_ip}:22"
done
```

RDP mapping loop:

```bash
for i in $(seq 0 19); do
  port=$((4389 + i))
  vm_ip="10.10.10.$((10 + i))"
  sudo iptables -t nat -A PREROUTING -d 136.243.106.138 -p tcp --dport "${port}" -j DNAT --to-destination "${vm_ip}:3389"
done
```

After adding DNAT rules, ensure the FORWARD chain allows the forwarded traffic (see section 5).

---

## 7) Persist iptables rules

Iptables rules are lost on reboot unless saved. Two common options:

- Install iptables-persistent (Debian/Ubuntu):

```bash
sudo apt-get install iptables-persistent
# during install, you will be prompted to save current rules
# or manually:
sudo netfilter-persistent save
```

- Or save rules and apply them at boot with a script that calls `iptables-restore` from a saved file:

```bash
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
# ensure a systemd unit or script restores this on boot, or use netfilter-persistent
```

Consider migrating to nftables if you prefer a modern firewall system.

---

## 8) Verify rules and connectivity

List NAT rules:

```bash
sudo iptables -t nat -L -n -v --line-numbers
```

List forwarding rules:

```bash
sudo iptables -L FORWARD -n -v --line-numbers
```

From a remote host, test connecting to the public address and port (e.g., `ssh -p 222 user@136.243.106.138`) and confirm the connection reaches the intended VM.

---

## 9) Helpful reminders / best practices

- If you administer the host remotely, be careful when flushing firewall rules — you may lock yourself out.
- Use strong authentication on forwarded services (key-based SSH, RDP with network-level authentication).
- Consider restricting DNAT rules to specific source IPs if only certain clients should connect.
- Keep a backup of current iptables rules before making large changes: `iptables-save > ~/iptables.backup`.
- Persist sysctl and iptables rules so they survive reboots.

---

If you want, I can:
- Produce a ready-to-run shell script that applies these rules (with safety checks).
- Convert the iptables rules to nftables equivalents.
- Add stricter FORWARD/INPUT rules to harden the host firewall.

Tell me which option you'd like next.
