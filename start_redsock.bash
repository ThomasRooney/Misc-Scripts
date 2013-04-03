#!/bin/bash

# Create new chain
sudo iptables -t nat -N REDSOCKS
 
# Ignore LANs and some other reserved addresses.
sudo iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN
sudo iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
sudo iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
sudo iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN
sudo iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
sudo iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
sudo iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN
sudo iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN

# Ignore DNS
# iptables -t nat -A REDSOCKS --dport 53 -j RETURN
# iptables -t nat -A REDSOCKS --sport 53 -j RETURN
 
# Anything else should be redirected to port 4123
sudo iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 4123
 
#####

# Create new chain
#sudo iptables -t nat -N REDSOCKS_UDP

# Ignore LANs and some other reserved addresses.
#sudo iptables -t nat -A REDSOCKS_UDP -d 0.0.0.0/8 -j RETURN
#sudo iptables -t nat -A REDSOCKS_UDP -d 10.0.0.0/8 -j RETURN
#sudo iptables -t nat -A REDSOCKS_UDP -d 127.0.0.0/8 -j RETURN
#sudo iptables -t nat -A REDSOCKS_UDP -d 169.254.0.0/16 -j RETURN
#sudo iptables -t nat -A REDSOCKS_UDP -d 172.16.0.0/12 -j RETURN
#sudo iptables -t nat -A REDSOCKS_UDP -d 192.168.0.0/16 -j RETURN
#sudo iptables -t nat -A REDSOCKS_UDP -d 224.0.0.0/4 -j RETURN
#sudo iptables -t nat -A REDSOCKS_UDP -d 240.0.0.0/4 -j RETURN

# Ignore DNS
# iptables -t nat -A REDSOCKS_UDP --dport 53 -j RETURN
# iptables -t nat -A REDSOCKS_UDP --sport 53 -j RETURN

# Anything else should be redirected to port 4124
#sudo iptables -t nat -A REDSOCKS_UDP -p tcp -j REDIRECT --to-ports 4124
 

# Any tcp connection made by `thomas' is redirected
sudo iptables -t nat -A OUTPUT -p tcp -m owner --uid-owner thomas -j REDSOCKS
#sudo iptables -t nat -A OUTPUT -p udp -m owner --uid-owner thomas -j REDSOCKS_UDP

# Start the REDSOCKS instance
sudo /home/thomas/Misc/redsocks/redsocks -c /home/thomas/Misc/redsocks/redsocks.conf
