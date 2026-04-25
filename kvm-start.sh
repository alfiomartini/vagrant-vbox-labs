#!/bin/bash
#
# Reloads KVM modules for use with libvirt/Virt-Manager.
# Detects whether to load kvm_intel or kvm_amd based on hardware.
# Exit immediately if a command exits with a non-zero status.
set -e

echo "Checking for KVM modules..."

# 1. Identify hardware (Independent detection)
if grep -q "GenuineIntel" /proc/cpuinfo; then
    KVM_MOD="kvm_intel"
elif grep -q "AuthenticAMD" /proc/cpuinfo; then
    KVM_MOD="kvm_amd"
else
    echo "❌ Error: Could not detect CPU vendor (Intel/AMD)."
    exit 1
fi

# 2. Check current state
if lsmod | grep -q "$KVM_MOD"; then
    echo "KVM modules ($KVM_MOD) are already loaded. Nothing to do."
    exit 0
fi

# 3. Perform action
echo "Reloading $KVM_MOD..."
sudo modprobe kvm
sudo modprobe "$KVM_MOD"

# 4. Verify
echo "Verifying KVM is enabled..."
if lsmod | grep -q "$KVM_MOD"; then
    echo "✅ Success: KVM has been re-enabled."
else
    echo "❌ Error: Failed to reload KVM modules."
    exit 1
fi
