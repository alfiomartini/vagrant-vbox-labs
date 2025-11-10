#!/bin/bash
#
# Reloads KVM modules for use with libvirt/Virt-Manager.
# Exit immediately if a command exits with a non-zero status.
set -e

echo "Checking for KVM modules..."

if lsmod | grep -q "kvm_intel"; then
  echo "KVM modules are already loaded. Nothing to do."
  exit 0
fi

echo "Reloading KVM modules..."
sudo modprobe kvm
sudo modprobe kvm_intel

echo "Verifying KVM is enabled..."
if lsmod | grep -q "kvm_intel"; then
  echo "✅ Success: KVM has been re-enabled."
else
  echo "❌ Error: Failed to reload KVM modules."
  exit 1
fi
