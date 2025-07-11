# VirtualBox Network Mode: NAT

## Goals

## Summary of Bridged Mode 

## Key Learning Objectives

## Network Topology (VirtualBox Bridged Mode)

## The Vagrantfile Configuration

## Setup

## Prerequisites

## Prerequisites inside the VM's

## Getting Started

## Some Basic Experiments

### Checking Assigned IPv4 Addresses

```bash
vagrant@vm5:~$ ip -4 address show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 10.0.2.15/24 metric 100 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 86077sec preferred_lft 86077sec
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 192.168.0.84/24 metric 100 brd 192.168.0.255 scope global dynamic enp0s8
       valid_lft 86079sec preferred_lft 86079sec
```

### Testing Basic Internet Connectivity (ICMP)

```bash
vagrant@vm5:~$ ping -c3 www.google.com
PING www.google.com(2800:3f0:4001:815::2004 (2800:3f0:4001:815::2004)) 56 data bytes
64 bytes from 2800:3f0:4001:815::2004 (2800:3f0:4001:815::2004): icmp_seq=1 ttl=114 time=23.3 ms
64 bytes from 2800:3f0:4001:815::2004 (2800:3f0:4001:815::2004): icmp_seq=2 ttl=114 time=22.8 ms
64 bytes from 2800:3f0:4001:815::2004 (2800:3f0:4001:815::2004): icmp_seq=3 ttl=114 time=24.8 ms

--- www.google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2006ms
rtt min/avg/max/mdev = 22.756/23.615/24.836/0.886 ms
```


### Verifying Internet Access via Package Manager

```bash
vagrant@vm5:~$ sudo apt update
Hit:1 http://security.ubuntu.com/ubuntu jammy-security InRelease
Hit:2 http://archive.ubuntu.com/ubuntu jammy InRelease
Hit:3 http://archive.ubuntu.com/ubuntu jammy-updates InRelease
Hit:4 http://archive.ubuntu.com/ubuntu jammy-backports InRelease
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
77 packages can be upgraded. Run 'apt list --upgradable' to see them.
```

### Testing Inter-VM Connectivity

```bash
 ping -c3 192.168.0.85
PING 192.168.0.85 (192.168.0.85) 56(84) bytes of data.
64 bytes from 192.168.0.85: icmp_seq=1 ttl=64 time=2.13 ms
64 bytes from 192.168.0.85: icmp_seq=2 ttl=64 time=0.797 ms
64 bytes from 192.168.0.85: icmp_seq=3 ttl=64 time=0.868 ms

--- 192.168.0.85 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 0.797/1.264/2.128/0.611 ms
```

### Inspecting the Routing Table

```bash
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100 
default via 192.168.0.1 dev enp0s8 proto dhcp src 192.168.0.84 metric 100 
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15 metric 100 
10.0.2.2 dev enp0s3 proto dhcp scope link src 10.0.2.15 metric 100 
10.0.2.3 dev enp0s3 proto dhcp scope link src 10.0.2.15 metric 100 
181.213.132.4 via 192.168.0.1 dev enp0s8 proto dhcp src 192.168.0.84 metric 100 
181.213.132.5 via 192.168.0.1 dev enp0s8 proto dhcp src 192.168.0.84 metric 100 
192.168.0.0/24 dev enp0s8 proto kernel scope link src 192.168.0.84 metric 100 
192.168.0.1 dev enp0s8 proto dhcp scope link src 192.168.0.84 metric 100 
```

### Getting SSH Connection Details for Vagrant VM

### Transfering files into a Vagrant VM

### Observing NAT in Action (Why This Matters)

### Getting a Full Snapshot of Network Interface Configuration


## Key Takeaways

## Summary of Useful Commands