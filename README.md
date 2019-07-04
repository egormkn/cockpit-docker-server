# Cockpit + Docker Server Setup

This tutorial will help you set up the [Ubuntu Server](https://ubuntu.com/download/server/) with [Cockpit](https://cockpit-project.org/) control panel and [Docker](https://docs.docker.com/) support.

## Prerequisites:
- Ubuntu Server 18.04 with root access
- Domain name

## Tutorial

```bash
# Open ssh connection to SERVER as root
ssh root@SERVER
```

```bash
#####################
### INITIAL SETUP ### 
#####################

# https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-18-04

USERNAME="user"

# Create a new user
adduser $USERNAME
# Add new user to the `sudo` group
usermod -aG sudo $USERNAME
# Update package registry
apt update
# Upgrade packages
apt upgrade
# Install packages required for this tutorial
apt install git curl gnupg2 ca-certificates lsb-release apt-transport-https gnupg-agent software-properties-common
# Reboot
shutdown -r now
```

```bash
# Open ssh connection to SERVER as normal user
ssh user@SERVER
```

```bash
#################
# INSTALL NGINX #
#################

# https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04

# Install Nginx from Ubuntu repository for better compatibility
sudo apt install nginx
```

```bash
####################
# INSTALL FIREWALL #
####################

# Install UFW
sudo apt install ufw
# List network applications
sudo ufw app list
# Add firewall rules for SSH and Nginx 
sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
# Enable firewall (make sure you have allowed SSH before)
sudo ufw enable
```

```bash
##################
# INSTALL DOCKER #
##################

# https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# Set up the repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# Install the latest version of Docker
sudo apt install docker-ce docker-ce-cli containerd.io
# Check docker service status
systemctl status docker
```

```bash
######################
# INSTALL DOCKER-GEN #
######################

# https://github.com/jwilder/docker-gen

# Download release archive
wget https://github.com/jwilder/docker-gen/releases/download/0.7.3/docker-gen-linux-amd64-0.7.3.tar.gz
# Extract binary executable
sudo tar xvzf docker-gen-linux-amd64-0.7.3.tar.gz -C /usr/local/bin/
# Check installed version
docker-gen --version
```

```bash
###################
# INSTALL COCKPIT #
###################

# https://cockpit-project.org/running.html#ubuntu

# Install cockpit and docker plugin
sudo apt install cockpit cockpit-docker
```

```bash
###################
# INSTALL CERTBOT #
###################

# https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx

# Set up the repository
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
# Install the latest version of certbot
sudo apt install certbot python-certbot-nginx
```

```bash
#########
# SETUP #
#########

# https://github.com/cockpit-project/cockpit/wiki/Proxying-Cockpit-over-NGINX

DOMAIN="cockpit.example.com"

# Get config files
git clone https://github.com/egormkn/cockpit-docker-server.git
cd cockpit-docker-server
# Install all configuration files
sudo cp -R etc/ /
# Allow execution of update script
sudo chmod +x /etc/docker-gen/update.sh
# Set domain name in configuration file
sudo sed -i "s/cockpit.example.com/$DOMAIN/g" /etc/nginx/sites-available/cockpit
# Check that sites-enabled exists
sudo mkdir /etc/nginx/sites-enabled/
# Disable default server block
sudo rm -f /etc/nginx/sites-enabled/default
# Enable cockpit server block
sudo ln -sfn /etc/nginx/sites-available/cockpit /etc/nginx/sites-enabled/
# Setup SSL for cockpit
sudo certbot certonly --nginx -d $DOMAIN
# Enable docker server block
sudo ln -sfn /etc/nginx/sites-available/docker /etc/nginx/sites-enabled/
# Reload services
sudo systemctl daemon-reload
# Enable docker-gen service
sudo systemctl enable docker-gen.service
sudo systemctl status docker-gen.service
```

## Run Docker containers with domain name

```bash
sudo docker run -e VIRTUAL_HOST=test.cockpit.example.com -P -d nginxdemos/hello
```

## Useful links
https://tutorials.technology/tutorials/30-how-to-use-nginx-reverse-proxy-with-docker.html
https://blog.ippon.tech/set-up-a-reverse-proxy-nginx-and-docker-gen-bonus-lets-encrypt/
https://traefik.io/
https://chrissainty.com/how-i-dockerised-my-blog/
https://github.com/jwilder/nginx-proxy
