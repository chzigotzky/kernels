Node:

Is IP forwarding enabled?

Check: sysctl net.ipv4.ip_forward

/etc/sysctl.conf (This file is automatically loaded by the system at every boot.)

Entry in /etc/sysctl.conf: net.ipv4.ip_forward=1

sysctl -p takes effect immediately (effective even before reboot)

---

NAT (Masquerade) enabled?

iptables -t nat -L | grep MASQUERADE

If missing, set the following rule:

Host: iptables -t nat -A POSTROUTING -s 10.244.0.0/16 -j MASQUERADE

10.244.0.0/16: Default pod cluster network for the Flannel CNI (Entire address range of the pods. All pods on all nodes receive IPs from this range. Flannel divides this range into smaller subnets per node.)

One subnet per node from the Flannel pod cluster network:

Node A → 10.244.1.0/24
Node B → 10.244.2.0/24
Node C → 10.244.3.0/24

CNI = Container Network Interface

Pod A (10.244.1.5)
    │
    ▼
cni0
    │
    ├───────────────► Destination: 10.244.2.7 (Pod B)
    │                 → Forwarded via flannel.1
    │                 → NO NAT
    │
    ▼
Routing decision
    │
    ├───────────────► Destination: Internet (e.g., 8.8.8.8)
    │
    ▼
iptables (NAT/POSTROUTING)
    │
    ▼
MASQUERADE → Node IP (192.168.1.10)
    │
    ▼
eth0 → out to the network

In Kubernetes on the node, for example, a flannel.1 VXLAN tunnel interface is used to reach other nodes.

ip addr show flannel.1 (ip a flannel.1)

inet 10.244.1.0/32 scope global flannel.1 (This is a VXLAN endpoint to which multiple nodes are connected.)

---

The other nodes are visible in the routing table (ip route show):

10.244.1.0/24 dev cni0 proto kernel scope link src 10.244.1.1 (subnet entry for the node you are currently on)

10.244.2.0/24 via 10.244.2.0 dev flannel.1
10.244.3.0/24 via 10.244.3.0 dev flannel.1

For each additional node, a new route is created via flannel.1. The route does not point to a gateway, but to a VXLAN endpoint.

        ┌──────────────────────┐
        │        Node A        │
        │----------------------│
        │  cni0 (Bridge)       │
        │  10.244.1.1/24       │
        │       │              │
        │      Pods            │
        │  10.244.1.x          │
        │                      │
        │  flannel.1 (VXLAN)   │◄───────────────┐
        │  10.244.1.0/32       │                │
        └──────────────────────┘                │ VXLAN Tunnel (UDP 8472)
                                                │
        ┌──────────────────────┐                │
        │        Node B        │                │
        │----------------------│                │
        │  cni0 (Bridge)       │                │
        │  10.244.2.1/24       │                │
        │       │              │                │
        │      Pods            │                │
        │  10.244.2.x          │                │
        │                      │                │
        │  flannel.1 (VXLAN)   │◄───────────────┘
        │  10.244.2.0/32       │
        └──────────────────────┘


Routing to node A:
-------------------
10.244.1.0/24 dev cni0       → lokale Pods
10.244.2.0/24 via flannel.1  → Node B
10.244.3.0/24 via flannel.1  → Node C

Service IP:

A service IP is a virtual IP address that Kubernetes assigns to a service. This IP address remains consistent even if the pods on different nodes that have the `app` label which the service accesses are restarted or replaced.

…
kind: Service
…
selector:
    app: backend # This is where the pods with this label are selected.
…

---------

…
kind: Pod
…
metadata:
    …
    labels:
          app: backend
…

----------

1. MetalLB assigns an external IP address from the defined range and ensures that traffic is forwarded to the NGINX Ingress controller. It operates at Layer 2 and Layer 3 and does not take into account the URL being accessed.

2. The Ingress controller (e.g., NGINX) forwards everything to “/ -> kernel-dev-service” if no host is defined. Otherwise, use a host such as example.com and a path such as /api (API service). A single hostname can also be used for all services, in which case the paths must be different.

Otherwise, use a new hostname for each service.

With host:

rules:
    - host: example.com
       http:
            path: /

To ensure that the NGINX Ingress controller knows which service to select when multiple services are available, DNS or a host entry in /etc/hosts is used. DNS -> MetalLB IP (service.example.com -> MetalLB IP)

3. NGINX sends traffic to the service IP
4. kube-proxy replaces the destination: service IP → Pod B IP (e.g., 10.244.2.7. However, it does not know on which node this pod is running)
5. Now, standard network routing takes place:
If the pod is on a different node → Flannel transports the packet over the overlay network
If on the same node → locally and directly

Docker uses a bridge.

Host: inet 172.18.0.1/16 brd 172.18.255.255 scope global docker0
Container: eth0@if30 inet 172.18.0.2/16 brd 172.18.255.255 scope global eth0

Host: ip route show: 172.18.0.0/16 dev docker0 proto kernel scope link src 172.18.0.1

To access the Internet, NAT (masquerade) must also be enabled via iptables.

Is NAT (masquerade) enabled?

iptables -t nat -L | grep MASQUERADE

If something is missing, set a rule:

iptables -t nat -A POSTROUTING -s 172.17.0.0/16 -j MASQUERADE

---

In PROXMOX, a bridge (vmbr0) is used that is directly connected to a physical interface such as eth0, and the container is then assigned an IP address from the same subnet as the host.