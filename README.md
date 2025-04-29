# 🕵️‍♂️ StealthRecon - Stealthy Network Reconnaissance Tool

A stealthy Bash-based reconnaissance tool created for ethical hacking labs, Red Team simulations, and cybersecurity research. It performs passive and low-noise active recon techniques to mimic how adversaries operate in real-world scenarios.

---

## ⚙️ Features

- 🔍 Passive Recon (WHOIS, DNS, Host Info)
- 🧭 Slow, randomized ping sweep for stealth
- 🐙 Nmap stealth scan using MAC spoofing & decoys
- 📡 Optional passive sniffing with tcpdump
- 🧾 All output logged with timestamped files

---

## 🛠️ Requirements

Make sure these tools are installed on your Kali or Linux machine:

- `nmap`
- `macchanger`
- `tcpdump`
- `whois`
- `dig`
- `host`
- `nslookup`

Install them using:
```bash
sudo apt install nmap macchanger tcpdump whois dnsutils net-tools
