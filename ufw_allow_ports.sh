#!/bin/bash

# Basic ports
ufw allow 20
ufw allow 22
ufw allow 80
ufw allow 2020
ufw allow 2022
ufw allow 8080

# Range: 25570 → 26227 (200 ports, step of 3)
for port in $(seq 25570 3 26227); do
    ufw allow $port
done

# Reload firewall to apply changes
ufw reload
