# Quick Start: NAT Lab

This lab is specifically designed to be run on a **Linux Host**.

## The KVM vs. VirtualBox Conflict

On Linux, VirtualBox and KVM (the kernel's built-in hypervisor) both require exclusive access to the CPU's hardware virtualization extensions (Intel VT-x or AMD-V). Because these hardware features can only be owned by one hypervisor at a time, you cannot run them simultaneously. If KVM is loaded, VirtualBox will fail with errors like `VERR_VMX_IN_VMX_ROOT_MODE`.

### Switching Hypervisors

To resolve this, you must switch between hypervisor modules depending on which tool you need. Use the provided automation scripts in the project root:

**1. To use VirtualBox (for this lab):**
Run the following script to unload the KVM modules:

```bash
../vbox-start.sh
```

**2. To restore KVM (when finished):**
Run the following script to reload the KVM modules.This is required to use **virt-manager** or other KVM-based virtualization tools:

```bash
../kvm-start.sh
```

## Basic Vagrant Commands

Run these commands from within the `NAT/` directory:

| Command              | Description                                  |
| -------------------- | -------------------------------------------- |
| `vagrant up`         | Create and start both VMs (`vm1` and `vm2`). |
| `vagrant ssh vm1`    | Connect to the first VM.                     |
| `vagrant ssh vm2`    | Connect to the second VM.                    |
| `vagrant halt`       | Gracefully shut down the VMs.                |
| `vagrant destroy -f` | Completely remove the VMs and their disks.   |
