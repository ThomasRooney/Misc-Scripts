#!/bin/bash

sudo iptables -F
sudo iptables -X 
sudo iptables -Z
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t nat -Z
sudo killall redsocks
