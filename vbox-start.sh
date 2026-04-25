#!/bin/bash
#
# Unloads KVM modules to allow VirtualBox to run with hardware acceleration.
# Detects whether to unload kvm_intel or kvm_amd based on hardware.
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
if ! lsmod | grep -q "$KVM_MOD"; then
    echo "KVM modules ($KVM_MOD) are not loaded. Nothing to do."
    exit 0
fi

# 3. Perform action
echo "Unloading $KVM_MOD..."
sudo modprobe -r "$KVM_MOD"

# 4. Verify
echo "Verifying KVM is disabled..."
if ! lsmod | grep -q "kvm"; then
    echo "✅ Success: KVM has been disabled. You can now start VirtualBox."
else
    echo "❌ Error: Failed to unload KVM modules."
    exit 1
fi
