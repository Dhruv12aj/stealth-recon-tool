#!/bin/bash

# Check if target IP is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <target_ip>"
  exit 1
fi

TARGET=$1

echo "[*] Starting vulnerability assessment for $TARGET..."

# Step 1: Scan for open TCP ports using Nmap
echo "[*] Scanning for open TCP ports..."
nmap -Pn -sS -T4 -p- --open -oG open_ports.txt $TARGET

# Extract open ports
OPEN_PORTS=$(grep -oP '\d+/open' open_ports.txt | cut -d '/' -f1 | tr '\n' ',' | sed 's/,$//')

echo "[*] Open ports found: $OPEN_PORTS"

# Step 2: Detect OS using Nmap
echo "[*] Detecting operating system..."
nmap -O $TARGET -oN os_detection.txt

# Step 3: Check for EternalBlue vulnerability using Metasploit
echo "[*] Checking for EternalBlue vulnerability..."
msfconsole -q -x "
use auxiliary/scanner/smb/smb_ms17_010;
set RHOSTS $TARGET;
run;
exit;
"

echo "[*] Vulnerability assessment completed."
