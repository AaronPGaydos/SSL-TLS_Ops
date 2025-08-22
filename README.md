# 🔐 SSL-TLS_Ops with Certbot + Nginx

## Overview

This lab shows how to:
- Deploy Let's Encrypt certs on Nginx
- Simulate cert expiration and misconfig
- Auto-renew with cron
- Troubleshoot SSL issues like an SRE


🧰 Tech Stack:

VM: Ubuntu Server 24.04 or CentOS 8 via VMware Workstation

Web Server: Nginx

TLS Tooling: OpenSSL + Certbot

Monitoring: cron, curl, systemctl, and log analysis

# 1. Setup
Install a VM with CentOS or Ubuntu Server

Install Nginx:

sudo apt install nginx   # Ubuntu  
sudo systemctl enable --now nginx

Verify with: curl http://localhost

<img width="640" height="475" alt="Screenshot 2025-07-19 162238" src="https://github.com/user-attachments/assets/e1ce3872-469c-426c-97bc-c3d4a199f88d" />

# 2. Simulate 
Generate TLS Materials

- mkdir -p ~/ssl-lab/selfsigned && cd ~/ssl-lab/selfsigned
- openssl genrsa -out server.key 2048
- openssl req -new -key server.key -out server.csr
- openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

Nginx Config:

server {

    listen 443 ssl;
    ssl_certificate /home/youruser/ssl-lab/selfsigned/server.crt;
    ssl_certificate_key /home/youruser/ssl-lab/selfsigned/server.key;
    ...
    }

sudo nginx -t && sudo systemctl reload nginx

<img width="747" height="780" alt="Screenshot 2025-07-25 125602" src="https://github.com/user-attachments/assets/faf250a8-3d0b-4b48-bdd2-3e9b98fa142f" />

# 3. Root Cause Analysis (Cert Errors)
Break it:

mv server.key server.key.bak && sudo systemctl reload nginx

browser/curl should now fail.

curl -v https://localhost

<img width="606" height="476" alt="Screenshot 2025-07-25 130854" src="https://github.com/user-attachments/assets/515543d0-f109-488f-9497-5cd59f5c08cf" />

# 4. Remediation & Automation (Let's Encrypt)

Buy a domain (Freenom or Namecheap)

Point it to your VM (local test):

sudo nano /etc/hosts

Add:
192.168.56.100   www.yourdomain.com

Install Certbot

#if not already created
python3 -m venv /opt/certbot
source /opt/certbot/bin/activate
pip install --upgrade pip
pip install certbot certbot-nginx

symlink it for convenience
sudo ln -s /opt/certbot/bin/certbot /usr/local/bin/certbot

Run certbot with Nginx:

sudo certbot --nginx -d www.yourdomain.com

<img width="59" height="16" alt="image" src="https://github.com/user-attachments/assets/1e3dfada-48e5-47c4-a538-ede317a24d75" />

<img width="564" height="162" alt="Screenshot 2025-08-22 171000" src="https://github.com/user-attachments/assets/0ed429d4-dfe6-42a1-9804-283026a7150a" />

# 5. Monitoring, Alerting, & Hardening

Dry-run renewal:
sudo certbot renew --dry-run

Cron Auto-Renew

sudo crontab -e
#Add:
0 3 * * * certbot renew --quiet && systemctl reload nginx

<img width="470" height="29" alt="image" src="https://github.com/user-attachments/assets/314b6252-5166-4996-bb3f-f241bd04b213" />

# 7. Slack Test Summary

```text
🧨 Incident: HTTPS outage on www.aarondomain.com  
🕒 Timeline:  
- 02:00 PM – Pager alert triggered (TLS cert expired)  
- 02:05 PM – Initial triage: Nginx failed reload, browser showing untrusted site  
- 02:15 PM – RCA: Missing renewal automation, cert expired silently  
- 02:30 PM – Mitigation: Issued new Let's Encrypt cert via `certbot --nginx`  
- 02:45 PM – Verification: HTTPS restored, monitoring checks green  

🔍 Root Cause:  
Certbot not installed → no auto-renewal → cert expired undetected  

🔧 Fix Implemented:  
- Installed Certbot + Nginx plugin  
- Configured cron-based auto-renew + dry-run validation  
- Added custom SSL expiry monitoring script  

🚀 Action Items:  
- [ ] Add Slack alert when SSL cert <15 days to expire  
- [ ] Integrate monitoring with Prometheus/Grafana  
- [ ] Expand chaos tests to simulate DNS failures
