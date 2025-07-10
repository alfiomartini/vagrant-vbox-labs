#!/bin/bash

echo -e "\n=== Interface Information with Neighbors ===\n"

for IFACE in $(ls /sys/class/net); do
  echo "Interface: $IFACE"

  # Get own IP (if any)
  MY_IP=$(ip -4 -br addr show "$IFACE" | awk '{print $3}')
  
  # Get MAC address (might be empty for lo)
  MY_MAC=$(cat /sys/class/net/$IFACE/address 2>/dev/null)

  echo "  - Your IP:  ${MY_IP:-none}"
  echo "  - Your MAC: ${MY_MAC:-n/a}"

  if [[ "$IFACE" == "lo" ]]; then
    echo "  - Neighbors: (loopback — no neighbors)"
  else
    NEIGHBORS=$(ip -4 neigh show dev "$IFACE")
    if [ -n "$NEIGHBORS" ]; then
      echo "  - Neighbors:"
      echo "$NEIGHBORS" | awk '{
        ip=$1; mac="n/a"; state="UNKNOWN";
        for(i=1; i<=NF; i++) {
          if ($i == "lladdr") mac=$(i+1);
          else if ($i ~ /^(REACHABLE|STALE|DELAY|PROBE|FAILED|INCOMPLETE)$/) state=$i;
        }
        printf "      • %-15s → %-17s (%s)\n", ip, mac, state
      }'
    else
      echo "  - Neighbors: none"
    fi
  fi
  echo ""
done