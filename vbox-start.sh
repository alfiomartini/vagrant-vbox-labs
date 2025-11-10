#!/bin/bash
#
# Unloads KVM modules to allow VirtualBox to run with hardware acceleration.
# Exit immediately if a command exits with a non-zero status.
set -e

echo "Checking for KVM modules..."

if ! lsmod | grep -q "kvm"; then
  echo "KVM modules are not loaded. Nothing to do."
  exit 0
fi

echo "Unloading KVM modules..."
sudo modprobe -r kvm_intel 

echo "Verifying KVM is disabled..."
if ! lsmod | grep -q "kvm"; then
  echo "✅ Success: KVM has been disabled. You can now start VirtualBox."
else
  echo "❌ Error: Failed to unload KVM modules."
  exit 1
fi
