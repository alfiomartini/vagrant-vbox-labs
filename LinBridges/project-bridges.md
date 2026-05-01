# Future Lab Extensions: Advanced Linux Networking

The following are technically grounded extensions for a future lab, building upon the current Linux Bridge and TAP interface setup.

## 1. Inter-Bridge Connectivity (Trunking)
*   **The Setup:** Create a second bridge (`br-ext`) and connect it to `br-int` using a `veth` pair.
*   **The Learning Goal:** This simulates the physical connection between two switches. 
*   **Technical Observation:** It allows students to observe how a single Layer 2 segment (broadcast domain) can span across two discrete software devices. It also creates a foundation for learning **VLAN Trunking** (802.1Q), where a single `veth` pair carries traffic for multiple isolated subnets.

## 2. Network Namespace (NetNS) Integration
*   **The Setup:** Create a network namespace on the host, place an IP on one end of a `veth` pair inside that namespace, and attach the other end to `br-int`.
*   **The Learning Goal:** This demonstrates **Kernel-Level Isolation**. 
*   **Technical Observation:** The student can observe a process running in a namespace (on the host) communicating with a VM (in the hypervisor) as if they were on the same physical wire. This clarifies that a "Namespace" and a "VM" are simply different ways to isolate the network stack, both of which can meet at the same bridge.

## 3. Container-to-VM Hybrid Lab
*   **The Setup:** Run a container (via Docker or Podman) and use a `veth` pair to bridge its networking into the lab's `br-int`.
*   **The Learning Goal:** To understand **Converged Infrastructure**.
*   **Technical Observation:** In many production environments (like OpenStack or AWS), VMs and Containers must share the same network resources. This scenario allows for the study of how `iptables` rules on the host manage traffic crossing between the container bridge (`docker0`) and the manual lab bridge (`br-int`).

## Summary of the Learning Value
These extensions would shift the student's perspective from **Network Attachment** (how to connect a VM) to **Network Architecture** (how to connect different isolated environments). 

Using `veth` pairs in these contexts is technically appropriate because the connection is between two points within the same kernel (Bridge-to-Bridge or Bridge-to-Namespace), whereas TAP interfaces remain the correct choice for the Kernel-to-Process boundary of the VMs.
