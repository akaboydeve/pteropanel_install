To use the installation scripts, simply run this command as root. The script will ask you whether you would like to install just the panel, just Wings or both.

```bash
bash <(curl -s https://pterodactyl-installer.se)
```
ports
```
25900, 25903, 25906, 25909, 25912, 25915, 25921, 25924, 25927, 25930,  
25933, 25936, 25939, 25942, 25945, 25951, 25954, 25957, 25960, 25963,  
25966, 25969, 25972, 25975, 25990, 25993, 25996, 25999, 26002, 26005,  
26011, 26014, 26017, 26020, 26023, 26026, 26029, 26032, 26035, 26041,  
26044, 26047, 26050, 26053, 26056, 26059, 26062, 26065, 26071, 26074,  
26077, 26083, 26089, 26092, 26095, 26101, 26104, 26107, 26110, 26113,  
26116, 26119, 26122, 26125, 26131, 26134, 26137, 26140, 26143, 26146,  
26149, 26152, 26155, 26161, 26164, 26167, 26170, 26173, 26179, 26192,  
26195, 26201, 26203, 26206, 26209, 26212, 26215, 26221, 26224, 26227,
```

ufw allow script
```bash
bash <(curl -s https://raw.githubusercontent.com/akaboydeve/pteropanel_install/refs/heads/main/ufw_allow_ports.sh)
```

node status api Run the following command on your VPS:

```
bash <(curl -s https://raw.githubusercontent.com/akaboydeve/vps_status_nodeapi/main/install.sh)
```

Swap Setup Run the following command on your VPS:

```
bash <(curl -s https://raw.githubusercontent.com/akaboydeve/swap_setup_linux/refs/heads/main/swap_setup.sh)
```

Auto Restart Run the following command on your VPS:

```
bash <(curl -s https://raw.githubusercontent.com/akaboydeve/vps-autorestart/refs/heads/main/setup.sh)
```
