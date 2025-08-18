# SSL-TLS_Ops

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

