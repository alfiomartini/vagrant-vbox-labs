# VirtualBox Network Modes with Vagrant 

This project was inspired by the excelent [article/post](https://www.nakivo.com/blog/virtualbox-network-setting-guide/) on VirtualBox Network Settings by the Nakivo Team. We revisit most of the network settings explored in that post through a series of Labs. Each Lab define its set of VMs using Vagrant instead of the VirtualBox GUI.

Each Lab/Network Mode is comprised of:
- A Vagranfile configuration
- A very detailed README with sections for Goals, Network Mode Summary, Network Topology, Configuration Explanation, Setup, a Collection of Network Experiments, and a set of Tables with the most useful commands used in the Lab.

The Labs included in this project are:

- [NAT](./NAT/README.md)
- [Internal Network](./Internal/README.md) - (under revision)
- [Bridged](./Bridged/README.md) - (under construction)
- (...remaining network modes...)