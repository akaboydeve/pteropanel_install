#!/bin/bash

# Basic ports
ufw allow 20
ufw allow 22
ufw allow 80
ufw allow 2020
ufw allow 2022
ufw allow 8080

# Define range (25570 → 26227, step = 3)
start=25570
end=26227
step=3

# Generate list of ports
ports=($(seq $start $step $end))
total=${#ports[@]}
count=0

echo "Opening $total ports (range: $start → $end, step: $step)..."

# Loop through ports and show progress
for port in "${ports[@]}"; do
    ufw allow $port >/dev/null 2>&1
    ((count++))
    percent=$((count * 100 / total))
    echo -ne "\rProgress: $count/$total ports done ($percent%)"
done

echo -e "\nAll ports opened successfully."

# Reload firewall to apply changes
ufw reload
