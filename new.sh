 #!/bin/bash

# StealthRecon - A Stealthy Network Reconnaissance Tool
# Author: You
# Use ethically for internal Red Teaming

read -p "Enter target domain or IP: " target
logfile="stealthrecon_$(date +%F_%H-%M-%S).log"

# Check input
if [ -z "$target" ]; then
  echo "Usage: $0 <target-domain-or-IP>"
  exit 1
fi

echo "[*] Starting stealth recon on $target..." | tee -a $logfile

# -----------------------
# Passive Recon Function
# -----------------------
passive_recon() {
  echo "[*] Passive Recon..." | tee -a $logfile
  echo "[+] WHOIS Info:" | tee -a $logfile
  whois $target 2>/dev/null | tee -a $logfile

  echo "[+] DNS Records:" | tee -a $logfile
  dig $target any +short 2>/dev/null | tee -a $logfile
  host $target 2>/dev/null | tee -a $logfile
  nslookup $target 2>/dev/null | tee -a $logfile
}

# -----------------------
# Slow Ping Sweep Function
# -----------------------
slow_ping_sweep() {
  echo "[*] Slow Ping Sweep (class C subnet)..." | tee -a $logfile
  subnet=$(echo $target | cut -d'.' -f1-3)
  for i in $(seq 1 254); do
    (
      ip="$subnet.$i"
      ping -c 1 -W 1 $ip &>/dev/null && echo "[+] Host up: $ip" | tee -a $logfile
    ) &
    sleep $((RANDOM % 5 + 1))
  done
  wait
}

# -----------------------
# Stealthy Nmap Scan Function
# -----------------------
stealthy_nmap() {
  echo "[*] Nmap Stealth Scan..." | tee -a $logfile
  nmap -T1 -Pn --spoof-mac 0 -D RND:10 $target | tee -a $logfile
}

# -----------------------
# MAC Spoofing Function
# -----------------------
mac_spoof() {
  iface=$(ip route | grep default | awk '{print $5}' | head -n 1)
  echo "[*] Spoofing MAC on interface $iface..." | tee -a $logfile
  sudo ifconfig $iface down
  sudo macchanger -r $iface | tee -a $logfile
  sudo ifconfig $iface up
}

# -----------------------
# Passive Sniffing (Optional)
# -----------------------
passive_sniff() {
  echo "[*] Capturing 50 packets from $iface..." | tee -a $logfile
  sudo tcpdump -i $iface -nn -c 50 > tcpdump_capture.txt &
  sleep 10
  sudo pkill tcpdump
  echo "[+] Packets saved to tcpdump_capture.txt" | tee -a $logfile
}

# -----------------------
# MAIN LOGIC
# -----------------------

mac_spoof
passive_recon
slow_ping_sweep
stealthy_nmap
# passive_sniff  # Uncomment if you want to sniff traffic

echo "[*] Recon complete. Logs saved to $logfile" 
