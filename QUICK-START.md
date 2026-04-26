# Quick Start Guide

This project is specifically designed to be run on a **Linux Host**.

## The KVM vs. VirtualBox Conflict

On Linux, VirtualBox and KVM (the kernel's built-in hypervisor) both require exclusive access to the CPU's hardware virtualization extensions (Intel VT-x or AMD-V). You cannot run them simultaneously.

### Switching Hypervisors
Use these scripts in the project root to switch between tools:

**1. To use VirtualBox (for these labs):**
```bash
./vbox-start.sh
```

**2. To restore KVM (when finished):**
This is required to use **virt-manager** or other KVM-based tools.
```bash
./kvm-start.sh
```

---

## How to Run a Lab

Vagrant commands must be executed from within the specific network mode directory you want to experiment with.

**1. Open your terminal in the project root.**

**2. Navigate to the desired lab folder:**
```bash
cd NAT/      # For NAT mode
# OR
cd Bridged/  # For Bridged mode
# OR
cd Internal/ # For Internal mode
```

**3. Run the Vagrant commands:**

| Command | Description |
|---------|-------------|
| `vagrant up` | Create and start the VMs for the lab. |
| `vagrant ssh vm1` | Connect to the first VM. |
| `vagrant halt` | Gracefully shut down the VMs. |
| `vagrant destroy -f` | Completely remove the VMs. |
