# VirtualBox Network Mode: Internal Network

## Goal

Understand the behavior of an isolated **Internal Network** and the requirements for providing it with external connectivity. In this lab, we configure `vm1` to act as the **gateway** for our isolated network. It uses three specific network interfaces: NAT for management, Internal to receive traffic from the other VMs, and Bridged to send that traffic to the internet. This setup allows us to manually configure three critical tasks that are usually automated: enabling IPv4 forwarding so the machine can pass traffic from one network interface to another, translating the private 192.168.23.x addresses into the Bridged interface's IP so the physical router can return the traffic (NAT masquerade), and manually telling the other VMs to use `vm1` as their new path for external traffic (default route redirection).

## Summary of Internal Network Mode

An Internal Network is a private virtual segment within the VirtualBox hypervisor. Unlike NAT or Bridged modes, it does not provide automated networking services such as DHCP or a default gateway.

**Key Characteristics:**

- **Isolation**: Connectivity is restricted to VMs on the same internal segment. For this lab, we have defined the **192.168.23.0/24** subnet for all internal communication.
- **Manual IP Management**: Since no DHCP server is provided by the hypervisor, IP addresses must be statically assigned within the guest operating systems.
- **Functional Transparency**: The absence of built-in hypervisor services allows for a clear observation of how routing and packet translation are implemented at the operating system level.

## Key Learning Objectives

- Understand the requirement for a VM with multiple network interfaces to bridge isolated segments.
- Implement and validate kernel-level IPv4 forwarding and NAT masquerading.
- Observe the effect of default route redirection on path selection.

## Prerequisites

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](https://developer.hashicorp.com/vagrant/install)

## Prerequisites inside the VM's

- curl: `sudo apt update & sudo apt install curl`

## The Vagrantfile [Configuration](./Vagrantfile)

### Technical Overview

The Vagrantfile automates the deployment of a custom routing infrastructure. Instead of utilizing the hypervisor's built-in NAT, we implement a gateway using `vm1`.

- **The Gateway (vm1)**:
  This VM is configured with three network interfaces to pass traffic between networks:
  1. **NAT (eth0)**: Utilized by Vagrant for SSH management.
  2. **Internal (eth1)**: Connected to the isolated segment (`192.168.23.0/24`).
  3. **Bridged (eth2)**: Connected to the physical LAN to provide an external exit path.

- **The Internal Nodes (vm2, vm3)**:
  These nodes are connected to the internal segment and the management NAT interface. They lack a direct path to the physical LAN or the internet.

- **Provisioning**: The configuration automates the transition from isolation to connectivity:
  1. It enables IPv4 forwarding in the Linux kernel on `vm1`.
  2. It adds a NAT masquerade rule to the `iptables` POSTROUTING chain on `vm1`.
  3. It deletes the default route on the clients and adds a new default gateway pointing to `vm1`.

---

## Foundational Experiments

Before proceeding, ensure you have completed the [essential experiments in the NAT lab](../NAT/LAB-GUIDE.md#some-basic-experiments). You should be comfortable using `ip route` to see where traffic is sent and `ip addr` to check if your network interfaces are active and have the correct IPs.

---

## Guided Experiments

### 1. Mapping the Network Configuration (All VMs)

**Objective**: Verify the IP assignments and routing rules across the entire lab to understand the starting state.

Run `ip -br a` and `ip route` on **each VM**.

**vm1 (The Gateway)**:

```bash
vagrant@vm1:~$ ip -br a
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0             UP             10.0.2.15/24 fd17:625c:f037:2:a00:27ff:fe8d:c04d/64 fe80::a00:27ff:fe8d:c04d/64
eth1             UP             192.168.23.1/24 fe80::a00:27ff:fe65:9803/64
eth2             UP             192.168.0.104/24 2804:14d:4c58:806a:a00:27ff:fe19:c6bf/64 fe80::a00:27ff:fe19:c6bf/64

vagrant@vm1:~$ ip route
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
192.168.0.0/24 dev eth2 proto kernel scope link src 192.168.0.104
192.168.23.0/24 dev eth1 proto kernel scope link src 192.168.23.1

```

**vm2 & vm3 (The Clients)**:

```bash
vagrant@vm2:~$ ip -br a
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0             UP             10.0.2.15/24 fd17:625c:f037:2:a00:27ff:fe8d:c04d/64 fe80::a00:27ff:fe8d:c04d/64
eth1             UP             192.168.23.2/24 fe80::a00:27ff:fef8:c2e/64
vagrant@vm2:~$ ip route
default via 192.168.23.1 dev eth1
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
192.168.23.0/24 dev eth1 proto kernel scope link src 192.168.23.2
```

**What this tells us**:

- **On vm1 (The Gateway)**: 
  - **Network Interfaces**: `vm1` is present on three distinct networks. It has a NAT interface (`eth0`) for management, an internal interface (`eth1`) at **192.168.23.1** to serve the private segment, and a bridged interface (`eth2`) providing a direct footprint on your physical LAN.
  - **Direct Connectivity**: Its routing table shows three `proto kernel scope link` entries. This means the kernel recognizes all three networks as locally attached; `vm1` can send traffic to any of them without needing an external gateway of its own.

- **On the Clients (vm2 & vm3)**:
  - **Segment Participation**: They only have two interfaces. `eth0` is for management, and `eth1` connects them to the isolated internal subnet (**192.168.23.x**).
  - **Redirection**: Look at the `default` route. In standard NAT labs, this would point to VirtualBox's NAT engine (`10.0.2.2`). Here, it has been manually redirected to `192.168.23.1` via `eth1`. This is the routing logic of the lab: we are explicitly telling the clients to ignore their built-in exit path and send all external traffic to `vm1` instead.

### 2. Internal Connectivity: Direct vs. Routed Path

**Objective**: Determine if communication between `vm2` and `vm3` goes through the gateway (`vm1`) or directly over the internal wire.

From `vm2`, ping `vm3` and then inspect the neighbor table:
```bash
ping -c 3 192.168.23.3
ip -4  neighbor show

vagrant@vm2:~$ ping -c3 192.168.23.3
PING 192.168.23.3 (192.168.23.3) 56(84) bytes of data.
64 bytes from 192.168.23.3: icmp_seq=1 ttl=64 time=0.381 ms
64 bytes from 192.168.23.3: icmp_seq=2 ttl=64 time=0.281 ms
64 bytes from 192.168.23.3: icmp_seq=3 ttl=64 time=0.346 ms

--- 192.168.23.3 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 1998ms
rtt min/avg/max/mdev = 0.281/0.336/0.381/0.041 ms
vagrant@vm2:~$ ip -4 neighbor show
192.168.23.3 dev eth1 lladdr 08:00:27:ca:f6:0c REACHABLE
10.0.2.2 dev eth0 lladdr 52:55:0a:00:02:02 REACHABLE
192.168.23.1 dev eth1 lladdr 08:00:27:65:98:03 STALE
```

**Interpretation**:

1. **Direct Communication (Layer 2)**: When `vm2` pings `vm3` (192.168.23.3), it checks its routing table. Because the destination is in the same subnet, the OS sees it as `scope link` (reachable on the local segment). It then broadcasts an ARP request: *"Who has 192.168.23.3? Tell 192.168.23.2"*.
2. **The Evidence**: The fact that `ip neighbor` shows `192.168.23.3` associated with a specific MAC address (`08:00:27...`) means `vm2` and `vm3` successfully completed that handshake directly.

**Conclusion**: Seeing `vm3`'s IP and MAC in the table confirms they are communicating directly on the shared virtual segment without `vm1` intermediate intervention.

**Complementary Test: Pinging the Host**
If you ping your host machine (e.g., `ping -c 3 192.168.0.x`) and run `ip neighbor` again, the table will **not** change.
- **Why?**: Since the host is on a different network, `vm2` knows it cannot talk to it directly. Instead of asking "Who has 192.168.0.x?" (ARP), it simply hands the packet to the gateway it already knows: **192.168.23.1**.
- **The Evidence**: `vm2` never needs the MAC address of the host, so it never performs an ARP request for that IP. It reuses the MAC address of `vm1` (the gateway) to encapsulate the packet for delivery.

### 3. Verifying the Gateway Configuration on vm1

**Objective**: Verify the **Gateway State** of `vm1`—the configuration that allows it to pass traffic between networks.

Run `sudo sysctl net.ipv4.ip_forward` and `sudo iptables -t nat -L POSTROUTING` on `vm1`.

```bash
vagrant@vm1:~$ sudo sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 1

vagrant@vm1:~$ sudo iptables -t nat -L POSTROUTING
Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  anywhere             anywhere
```

**Output Breakdown:**

- **`Chain POSTROUTING`**: Confirms we are looking at the iptables chain that triggers *after* the routing decision is made, just before the packet exits the network interface.
- **`policy ACCEPT`**: The default policy for this chain; packets that don't match any specific rule will still be allowed to pass.
- **`target (MASQUERADE)`**: The specific action taken. It tells the kernel to replace the source IP of matching packets with the IP of the exit interface.
- **`prot (all)`**: Indicates that the rule applies to all protocols (TCP, UDP, ICMP, etc.).
- **`source (anywhere)`**: Matches packets from any source address, effectively covering the entire `192.168.23.0/24` internal segment.
- **`destination (anywhere)`**: Matches packets destined for any external address (the internet or your physical LAN).

**Technical Breakdown:**

- **IPv4 Forwarding**: Even if `vm1` has the correct IPs, it will not pass packets between them unless `net.ipv4.ip_forward` is set to `1`. If this were `0`, `vm1` would drop any packet arriving from the clients that is destined for the internet.
- **NAT Masquerade**: The implementation of `iptables -t nat -A POSTROUTING -j MASQUERADE` completes the gateway configuration:
    - **`-t nat` (The Mechanism)**: By using the **NAT table**, we are not merely routing packets; we are actively rewriting their headers. This provides the foundation for **Topology Hiding**, as it allows `vm1` to alter the identity of the packets passing through it.
    - **`-A POSTROUTING` (The Timing)**: This chain intercepts packets at the last possible moment *after* the routing decision is made but *before* they exit the physical interface. This ensures that the transformation happens before the external network can see the original internal source IP, **preventing IP leakage**.
    - **`-j MASQUERADE` (The Action)**: This replaces internal source IPs with `vm1`'s external IP. This "masks" the internal segment, collapsing all nodes into a single external identity and creating a stateful boundary that only allows return traffic for established outbound sessions.

### 4. Path Validation (Traceroute)

**Objective**: Use `traceroute` to verify the multi-hop path when accessing external networks.

From `vm2`, run `traceroute -n 8.8.8.8`.

```bash
vagrant@vm2:~$ traceroute -n 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  192.168.23.1  0.900 ms  0.869 ms  0.808 ms
 2  10.0.2.2  0.791 ms  0.732 ms  0.715 ms
 3  192.168.0.1  4.086 ms  4.295 ms  4.411 ms
 4  189.6.144.1  6.184 ms  6.511 ms  6.548 ms
 ...
```

**What this means**:
The traceroute reveals the step-by-step path from the internal node to the internet:
1.  **Hop 1 (192.168.23.1)**: The packet arrives at `vm1` (our gateway).
2.  **Hop 2 (10.0.2.2)**: This is the VirtualBox NAT gateway. Its presence here tells us that `vm1` is routing our traffic out through its **eth0 (NAT)** interface rather than its **eth2 (Bridged)** interface. This happens because `vm1`'s default route is still pointing to the NAT engine.
3.  **Hop 3 (192.168.0.1)**: This is your physical WiFi router. It means the packet has finally left the VirtualBox environment and is on your physical LAN.
4.  **Hop 4+**: These are the public IPs of your ISP and the internet backbone.

**Conclusion**: This confirms the "Chain of Gateways." `vm2` -> `vm1` -> `VirtualBox NAT` -> `Physical Router` -> `Internet`. It also highlights that without manual priority (metrics), the Linux kernel on `vm1` favored the NAT interface as the exit point for the lab traffic.

### 5. Name Resolution and DNS

**Objective**: Test if the internal nodes can resolve external domain names.

From `vm2`, run `ping -c 3 google.com`.

```bash
vagrant@vm2:~$ ping -c3 google.com
PING google.com (172.217.30.110) 56(84) bytes of data.
64 bytes from pngrub-ag-in-f14.1e100.net (172.217.30.110): icmp_seq=1 ttl=254 time=141 ms
64 bytes from pngrub-ag-in-f14.1e100.net (172.217.30.110): icmp_seq=2 ttl=254 time=27.7 ms
64 bytes from pngrub-ag-in-f14.1e100.net (172.217.30.110): icmp_seq=3 ttl=254 time=49.4 ms

--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 1998ms
rtt min/avg/max/mdev = 27.685/72.589/140.690/48.963 ms
```

**What this means**:
In the output above, `ping google.com` succeeded. This might seem surprising because we only redirected **traffic** (Layer 3), not **DNS configuration**.

- **Why it works**: When `vm2` boots, it receives its DNS configuration via DHCP on the management interface (`eth0`). You can see the result by running `cat /etc/resolv.conf`. Even though we redirected the `default` route to `vm1`, the VM still attempts to contact those same DNS server IPs. Since those IPs are outside the local network, the traffic follows the new route through `vm1` to the internet.
- **The "Internal" Reality**: In a truly isolated environment (where Adapter 1 is disabled), this would fail instantly because the VM would have no DNS servers to query. This highlights that while we have taken control of the **path** (routing), the **logic** (DNS) is still inherited from the management network.

**Challenge**: If you were to run `echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf`, resolution would still work, but the query would now be a standard UDP packet routed through `vm1` to Cloudflare.

### 6. Service Visibility and Access Boundaries

**Objective**: Determine how network isolation and gateway positioning affect service reachability.

#### Part A: Internal Node Visibility (vm2)

1. **Start a server on vm2**: `vagrant ssh vm2` and run `python3 -m http.server 8080`.
2. **Test from vm3 (Peer)**: `curl -I 192.168.23.2:8080`.
3. **Test from vm1 (Gateway)**: `curl -I 192.168.23.2:8080`.
4. **Test from Host**: `curl -I 192.168.23.2:8080`

#### Part B: Gateway Visibility (vm1)

1. **Start a server on vm1**: `vagrant ssh vm1` and run `python3 -m http.server 8080`.
2. **Test from vm2 (Internal)**: `curl -I 192.168.23.1:8080`.
3. **Test from Host**: `curl -I <vm1-bridged-ip>:8080`.

**[INSERT OBSERVATIONS HERE]**

**What this means (Part A: vm2 server)**:
- **From vm3 (Peer)**: Success. Both are on the same virtual segment (`intnet-lab`). Traffic travels directly via the virtual switch.
- **From vm1 (Gateway)**: Success. `vm1` is physically connected to the same internal segment on its `eth1` interface.
- **From the Host**: **Failure**. This is the key lesson. Even though `vm1` is routing traffic *out* from `vm2`, it is not forwarding traffic *in*. This is due to the inherent isolation of the Internal Network and the lack of a destination NAT rule on `vm1` to handle unsolicited inbound traffic.

**What this means (Part B: vm1 server)**:
- **From vm2 (Internal)**: Success. `vm2` reaches the gateway via the internal IP (`192.168.23.1`) on the shared segment.
- **From the Host**: **Success**. `vm1` has its `eth2` interface connected to your physical network. This makes it directly reachable from your host machine, just like any other device on your local network.

**Conclusion**: The Internal Network is isolated from your host. While `vm1` can reach the internal nodes, your host cannot see them directly, even though it provides their path to the internet.

---

## Key Takeaways

### 1. Gateway as a Software State
We proved that a "gateway" isn't a special device, but a configuration. By enabling `net.ipv4.ip_forward` and adding an `iptables` masquerade rule, we transformed a standard VM into a router. Without these manual steps, `vm1` would have simply dropped the traffic from its peers.

### 2. Manual Path Control
By manipulating the `ip route` table on the client nodes, we forced the operating system to ignore its built-in NAT exit in favor of our custom gateway. The `traceroute` results confirmed this change, showing our internal IP (`192.168.23.1`) as the very first hop.

### 3. Layer 2 Isolation and Topology Hiding
The "Internal Network" is logically isolated from the host at Layer 2. The NAT Masquerade rule on `vm1` completes this isolation at Layer 3 by masking internal IP addresses behind a single external identity. This prevents internal topology leakage and ensures that the host can only communicate with the internal nodes if they initiate the connection first.

### 4. Layer 2 vs. Layer 3: The Neighbor Table Evidence
The `ip neighbor` check provided empirical proof of how the OS chooses its path. For local traffic (`vm2` to `vm3`), the table contains the peer's MAC address because they talk directly (Layer 2). For external traffic, the table only needs the gateway's MAC address, because the OS knows it must hand the packet to `vm1` (Layer 3) to reach any destination beyond the local wire.
