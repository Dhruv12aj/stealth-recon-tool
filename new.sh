!/bin/bash

# StealthRecon - A Stealthy Web Reconnaissance Tool
# Author: You
# Use ethically for internal Red Teaming

read -p "Enter target domain or URL (example: www.site.com or https://site.com): " url
logfile="stealthrecon_$(date +%F_%H-%M-%S).log"

# -----------------------
# Input validation
# -----------------------
if [[ -z "$url" ]]; then
  echo "Usage: $0 <domain or http(s)://domain>"
  exit 1
fi

# Extract clean domain from URL
domain=$(echo "$url" | sed -E 's~https?://~~;s~/.*~~')

# Reject raw IPs
if [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "[!] Please enter only domain names or URLs, not raw IP addresses."
  exit 1
fi

# Resolve IP with fallbacks
ip=$(dig +short "$domain" A | head -n 1)
if [ -z "$ip" ]; then
  ip=$(getent ahosts "$domain" | awk '{print $1; exit}')
fi
if [ -z "$ip" ]; then
  ip=$(ping -c1 "$domain" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
fi
if [ -z "$ip" ]; then
  ip="Could not resolve"
fi

echo "[*] Starting stealth recon on $domain (IP: $ip)..." | tee -a $logfile

# -----------------------
# Root check
# -----------------------
if [ "$EUID" -ne 0 ]; then
  echo "[!] Please run as root"
  exit 1
fi

# -----------------------
# Tool check
# -----------------------
for cmd in whois dig host nslookup nmap macchanger curl python3; do
  if ! command -v $cmd &>/dev/null; then
    echo "[!] $cmd not found. Please install it."
  fi
# -----------------------
# Tool check
# -----------------------
for cmd in whois dig host nslookup nmap macchanger curl python3; do
  if ! command -v $cmd &>/dev/null; then
    echo "[!] $cmd not found. Please install it."
  fi
done

# -----------------------
# MAC Spoofing
# -----------------------
mac_spoof() {
  iface=$(ip route | grep default | awk '{print $5}' | head -n 1)
  echo "[*] Spoofing MAC on interface $iface..." | tee -a $logfile
  sudo ifconfig $iface down
  sudo macchanger -r $iface | tee -a $logfile
  sudo ifconfig $iface up
}

# -----------------------
# Passive Recon
# -----------------------
passive_recon() {
  echo "[*] Passive Recon..." | tee -a $logfile

  echo "[+] WHOIS Info (short):" | tee -a $logfile
  whois $domain 2>/dev/null | egrep -i "Registrar|Creation Date|Updated Date|Expiry|Name Server" | tee -a $logfile

  echo "[+] DNS Records:" | tee -a $logfile
  dig $domain any +short 2>/dev/null | tee -a $logfile
  host $domain 2>/dev/null | tee -a $logfile
}
 
# -----------------------
# Web Recon using Python WHOIS
# -----------------------
web_recon() {
  echo "[*] Web Recon on $domain..." | tee -a $logfile
  echo "[+] Target Domain: $domain" | tee -a $logfile
  echo "[+] Target IP: $ip" | tee -a $logfile

  echo "[+] HTTP Headers:" | tee -a $logfile
  curl -s -I "http://$domain" | tee -a $logfile

  # WHOIS Lookup using Python
  echo "[+] WHOIS Info:" | tee -a $logfile
  python3 - <<END | tee -a $logfile
import whois
try:
    w = whois.whois("$domain")
    for key, value in w.items():
        print(f"{key}: {value}")
except Exception as e:
    print("[-] WHOIS lookup failed:", e)
END

  # Technology Fingerprinting
  if command -v whatweb &>/dev/null; then
    echo "[+] WhatWeb Results:" | tee -a $logfile
    whatweb "$domain" | tee -a $logfile
  else
    echo "[!] Install 'whatweb' for technology fingerprinting" | tee -a $logfile
  fi
}

# -----------------------
# Fast Nmap Scan
# -----------------------
stealthy_nmap() {
  if [ "$ip" != "Could not resolve" ]; then
    echo "[*] Nmap Scan on $ip (top 100 ports, fast mode)..." | tee -a $logfile
    nmap -T4 --top-ports 100 -Pn -n "$ip" | tee -a $logfile
  else
    echo "[!] Skipping Nmap scan (no IP resolved)" | tee -a $logfile
  fi
}

# -----------------------
# MAIN LOGIC
# -----------------------
mac_spoof
web_recon
passive_recon
stealthy_nmap

echo "[*] Recon complete. Logs saved to $logfile"
