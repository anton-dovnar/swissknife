#!/bin/bash

# Check if domain argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Assign the domain from argument
DOMAIN="$1"

# Install required packages
sudo apt install certbot python3-certbot-nginx -y

echo "
server {
  root /var/www/html;
  index index.html index.htm index.nginx-debian.html;
  server_name $DOMAIN www.$DOMAIN;
  location / {
    try_files \$uri \$uri/ =404;
  }
}
" | sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null

# Test Nginx configuration
sudo nginx -t

# Reload Nginx to apply changes
sudo systemctl reload nginx

# Obtain SSL certificate
sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN

# Check certbot timer status
sudo systemctl status certbot.timer

# Test certificate renewal
sudo certbot renew --dry-run
