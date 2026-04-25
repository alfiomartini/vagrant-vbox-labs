# =========================

# VM1 (router)

# =========================

## Bring up internal network interface (Adapter 1)

sudo ip link set enp0s3 up

## Assign IP to internal network

sudo ip addr add 192.168.23.1/24 dev enp0s3

## Bring up external interface (Adapter 2 - bridged)

sudo ip link set enp0s8 up

## Enable IP forwarding (allow VM1 to route packets between interfaces)

sudo sysctl -w net.ipv4.ip_forward=1

## Add NAT (only for internal subnet going out via external interface)

sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

or, if one wants to be more precise:

sudo iptables -t nat -A POSTROUTING -s 192.168.23.0/24 -o enp0s8 -j MASQUERADE

# =========================

# VM2

# =========================

## Bring up internal network interface

sudo ip link set enp0s3 up

## Assign IP

sudo ip addr add 192.168.23.2/24 dev enp0s3

## Set default gateway (VM1)

sudo ip route add default via 192.168.23.1

## Test connectivity

ping 192.168.23.1 # ping VM1
ping 8.8.8.8 # test internet

# =========================

# VM3

# =========================

## Bring up internal network interface

sudo ip link set enp0s3 up

## Assign IP

sudo ip addr add 192.168.23.3/24 dev enp0s3

## Set default gateway (VM1)

sudo ip route add default via 192.168.23.1

## Test connectivity

ping 192.168.23.1 # ping VM1
ping 8.8.8.8 # test internet

# =========================

# Optional verification (any VM)

# =========================

# Show interfaces and IPs

ip -br a

# Show routing table

ip route
