# Manual Linux Bridge & TAP Configuration Guide

This guide documents the fundamental process of building a virtual networking laboratory using Linux Bridges and TAP interfaces. This setup acts as a direct replacement for VirtualBox's "Internal Network" mode, using standard Linux kernel tools.

---

## 1. Network Topology & IP Plan

This topology exactly mirrors the `Internal/Vagrantfile` setup.

- **Lab Subnet:** `192.168.23.0/24`
- **Gateway (VM1):** `192.168.23.1` (The router between the Lab and the Internet)
- **Client 1 (VM2):** `192.168.23.2`
- **Client 2 (VM3):** `192.168.23.3`

---

## 2. Host Infrastructure Setup (Layer 2)

Run these commands on your Linux host to create the virtual switch and patch cables.

### A. Create the Virtual Switch (Bridge)

```bash
# Create the bridge (the software switch)
sudo ip link add name br-int type bridge

# Bring the bridge up
sudo ip link set br-int up
```

### B. Create and Patch the Virtual Cables (TAPs)

```bash
# Create a TAP interface for each VM
sudo ip tuntap add dev tap-vm1 mode tap
sudo ip tuntap add dev tap-vm2 mode tap
sudo ip tuntap add dev tap-vm3 mode tap

# "Plug" the TAPs into the bridge
sudo ip link set tap-vm1 master br-int
sudo ip link set tap-vm2 master br-int
sudo ip link set tap-vm3 master br-int

# Bring the TAPs up
sudo ip link set tap-vm1 up
sudo ip link set tap-vm2 up
sudo ip link set tap-vm3 up
```

---

## 3. VirtualBox Hardware Mapping

In the VirtualBox settings, map the "Adapters" to your Host TAPs. This determines the interface name (`eth0`, `eth1`, etc.) inside Linux.

### VM1 (The Router)

- **Adapter 1:** `NAT` -> Becomes `eth0` (Vagrant management/SSH) (not needed if creating VM's manually, in VBOX GUI)
- **Adapter 2:** `Bridged Adapter` -> Name: `tap-vm1` -> Becomes `eth1` (Internal Lab Side)
- **Adapter 3:** `Bridged Adapter` -> Name: `wlo1` (Your Physical NIC) -> Becomes `eth2` (External Internet Side)

### VM2 & VM3 (The Clients)

- **Adapter 1:** `NAT` -> Becomes `eth0`
- **Adapter 2:** `Bridged Adapter` -> Name: `tap-vmX` -> Becomes `eth1` (Internal Lab Side)

---

## 4. Guest OS Configuration (Layer 3)

Run these commands inside the virtual machines.

### A. Assign IP Addresses

```bash
# Inside VM1
sudo ip link set eth1 up
sudo ip addr add 192.168.23.1/24 dev eth1 (enp0s3)

# Inside VM2
sudo ip link set eth1 up
sudo ip addr add 192.168.23.2/24 dev eth1 (enp0s3)


# Inside VM3
sudo ip link set eth1 up
sudo ip addr add 192.168.23.3/24 dev eth1 (enp0s3)
```

Note 1: Here I can already ping each vm from one another, so it seems the br-int is working
Note 2: Here I can already ping my host (192.168.0.87) from vm1
Note 3: Here I can already ping vm1 (192.168.0.95) from the host
Note 4: Here I CAN'T ping vm1 (192.168.23.1) from the host (expected, I guess)
Note 5: Here I can ping the internet (8.8.8.8) from vm1
Note 6: Here I can't access the Internet from vm2 and vm3 (expected, I guess)

### B. Configure VM1 as the Gateway

```bash
# 1. Enable IPv4 Forwarding (allows passing packets between eth1 and eth2)
sudo sysctl -w net.ipv4.ip_forward=1

# 2. Setup NAT (Masquerading)
# Translates private lab traffic into your real network's IP.
sudo iptables -t nat -A POSTROUTING  -j MASQUERADE (used this version)
sudo iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE
```

### C. Configure Clients (VM2 & VM3)

```bash
# Replace the existing default route with our new internal gateway
sudo ip route replace default via 192.168.23.1 dev eth1 (enp0s3)
```

## Note 7: Now I have internet access from both vm1 and vm2

## 5. Verification & Monitoring

One of the best reasons to use Linux Bridges is the ability to "sniff" the wire from the host.

```bash
# List all active ports on the switch
bridge link show

# Sniff traffic on the internal network from your Host terminal
sudo tcpdump -i br-int -n

# Test connectivity from VM2 to the Internet
ping 8.8.8.8
```

---

## 6. Cleanup

```bash
# Deleting the bridge automatically detaches all ports
sudo ip link delete br-int

# Manually delete the TAP interfaces
sudo ip link delete tap-vm1
sudo ip link delete tap-vm2
sudo ip link delete tap-vm3
```

---

'As soon as VirtualBox starts the first VM:  
 1. VirtualBox "plugs into" tap-vm1.  
 2. tap-vm1 will lose its NO-CARRIER flag and become fully UP.  
 3. Because tap-vm1 is now active, the bridge br-int will automatically transition to UP.'
