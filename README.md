# Server Setup

Prerequisites:
- Ubuntu 18.04 with root access
- Domain name with DNS settings available

```bash
# Open ssh connection as root
ssh root@my-public-ip
```

```bash
#####################
### INITIAL SETUP ### 
#####################

# https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-18-04

# Create a new user
adduser egor
# Add new user to the sudo group
usermod -aG sudo egor
# Setup firewall
ufw app list
ufw allow OpenSSH
ufw enable
# Update registry
apt update
# Upgrade packages
apt upgrade
# Reboot
shutdown -r now
```

```bash
# Open ssh connection as normal user
ssh egor@my-public-ip
```

```bash
#################
# INSTALL NGINX #
#################

# https://nginx.org/ru/linux_packages.html#Ubuntu

sudo apt install curl gnupg2 ca-certificates lsb-release
echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
# Install package
sudo apt update
sudo apt install nginx
# Add firewall rule for nginx
sudo ufw app list
sudo ufw allow 'Nginx Full'
# Check nginx status
systemctl status nginx

##################
# INSTALL DOCKER #
##################

# https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository

# Install packages to allow apt to use a repository over HTTPS
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# Set up the stable repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# Install the latest version of Docker CE and containerd
sudo apt install docker-ce docker-ce-cli containerd.io

###################
# INSTALL COCKPIT #
###################

# https://cockpit-project.org/running.html#ubuntu

# Install the latest version of cockpit project
sudo apt-get install cockpit/bionic-backports cockpit-docker/bionic-backports cockpit-packagekit/bionic-backports
sudo ufw allow 9090
```

```bash
###############################
# SETUP COCKPIT REVERSE PROXY #
###############################

# https://github.com/cockpit-project/cockpit/wiki/Proxying-Cockpit-over-NGINX

# Create configuration file
sudo nano /etc/nginx/sites-available/cockpit.gear.su
```

```
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

upstream websocket {
    server 127.0.0.1:9090;
}

server {
    listen         80;
    server_name    cockpit.gear.su www.cockpit.gear.su;
    return         301 https://$server_name$request_uri;
}

server {
    listen 443;
    server_name cockpit.gear.su www.cockpit.gear.su;

    ssl on;
    ssl_certificate /etc/cockpit/ws-certs.d/0-self-signed.cert;
    ssl_certificate_key /etc/cockpit/ws-certs.d/0-self-signed.cert;

    location / {
        proxy_pass http://websocket;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header X-Real-IP  $remote_addr;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $remote_addr;
        # needed for websocket
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        # change scheme of "Origin" to http
        proxy_set_header Origin http://$host;

        # Pass ETag header from cockpit to clients.
        # See: https://github.com/cockpit-project/cockpit/issues/5239
        gzip off;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/cockpit.gear.su /etc/nginx/sites-enabled/

sudo nano /etc/nginx/nginx.conf
```

Uncomment line:

```
...
http {
    ...
    server_names_hash_bucket_size 64;
    ...
}
...
```

```bash
# Check nginx configs
sudo nginx -t
```

```bash
###################
# INSTALL CERTBOT #
###################

# https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx

sudo apt install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt update
sudo apt install certbot python-certbot-nginx

# Setup SSL
sudo certbot --nginx -d cockpit.gear.su -d www.cockpit.gear.su
# Test renewal
sudo certbot renew --dry-run
```

```bash
# Set protocol header for websockets
sudo nano /etc/cockpit/cockpit.conf
```

```
[WebService]
ProtocolHeader = X-Forwarded-Proto
```

```bash
##########################
# INSTALL DOCKER-COMPOSE #
##########################

# https://docs.docker.com/compose/install/

sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

######################
# INSTALL DOCKER_GEN #
######################


wget https://github.com/jwilder/docker-gen/releases/download/0.7.3/docker-gen-linux-amd64-0.7.3.tar.gz
sudo tar xvzf docker-gen-linux-amd64-0.7.3.tar.gz -C /usr/local/bin/
docker-gen --version

sudo mkdir -p /etc/docker-gen/
sudo wget https://github.com/jwilder/docker-gen/raw/master/templates/nginx.tmpl -O /etc/docker-gen/nginx.tmpl
sudo touch /etc/nginx/sites-available/docker
sudo ln -sfn /etc/nginx/sites-available/docker /etc/nginx/sites-enabled/

sudo docker-gen -only-published -watch -notify "/etc/init.d/nginx reload" /etc/docker-gen/nginx.tmpl /etc/nginx/sites-available/docker


wget https://github.com/getgrav/grav/releases/download/1.6.9/grav-admin-v1.6.9.zip
sudo unzip grav-admin-v1.6.9.zip -d /etc/grav/
sudo chown -R www-data:www-data /etc/grav/grav-admin

sudo docker run -e VIRTUAL_HOST=ocean.gear.su -v /etc/grav/grav-admin:/var/www/html:cached -p 8000:80/tcp grav:latest

sudo certbot --nginx certonly
```

Add certificates to template:

```

```


https://tutorials.technology/tutorials/30-how-to-use-nginx-reverse-proxy-with-docker.html
https://blog.ippon.tech/set-up-a-reverse-proxy-nginx-and-docker-gen-bonus-lets-encrypt/
https://traefik.io/
https://chrissainty.com/how-i-dockerised-my-blog/
https://github.com/jwilder/nginx-proxy

