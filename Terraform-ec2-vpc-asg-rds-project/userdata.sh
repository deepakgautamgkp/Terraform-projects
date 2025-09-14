#!/bin/bash
# Simple userdata: install nginx and a health endpoint
apt-get update
apt-get install -y nginx
cat > /var/www/html/index.html <<EOF
<html>
<head><title>Terraform ASG Demo</title></head>
<body>
<h1>Hello from $(hostname)</h1>
</body>
</html>
EOF
systemctl restart nginx
