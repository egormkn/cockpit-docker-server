# Server Setup

## Prerequisites:
- Ubuntu 18.04 with root access
- Domain name with DNS settings available

## Tutorial

```bash
# Open ssh connection as root
ssh root@my-public-ip
```

```bash
#####################
### INITIAL SETUP ### 
#####################

# https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-18-04

USERNAME="user"

# Create a new user
adduser $USERNAME
# Add new user to the sudo group
usermod -aG sudo $USERNAME
# Setup firewall
ufw app list
ufw allow OpenSSH
ufw enable
# Update registry
apt update
# Upgrade packages
apt upgrade
# Install necessary packages
sudo apt install curl gnupg2 ca-certificates lsb-release apt-transport-https gnupg-agent software-properties-common
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

# Add NGINX's official GPG key
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
# Set up the repository
sudo add-apt-repository "deb http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx"
# Install package
sudo apt install nginx
# Add firewall rule for nginx
sudo ufw app list
sudo ufw allow 'Nginx Full'
# Check nginx service status
systemctl status nginx
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
systemctl status nginx
```


```bash
##########################
# INSTALL DOCKER-COMPOSE #
##########################

# https://docs.docker.com/compose/install/

# Download binary release
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# Allow execution
sudo chmod +x /usr/local/bin/docker-compose
# Check installed version
docker-compose --version
```

```bash
######################
# INSTALL DOCKER_GEN #
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

# Install the latest version of cockpit from backports
sudo apt install cockpit/bionic-backports cockpit-docker/bionic-backports cockpit-packagekit/bionic-backports
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

DOMAIN="my.example.org"

# Install all configuration files
sudo cp -R etc/ /
# Set domain name in configuration file
sudo sed -i "s/example.com/$DOMAIN/g" /etc/nginx/sites-available/cockpit
# Enable cockpit server block
sudo ln -sfn /etc/nginx/sites-available/cockpit /etc/nginx/sites-enabled/
# Setup SSL for cockpit
sudo certbot certonly --nginx -d $DOMAIN
# Enable docker server block
sudo ln -sfn /etc/nginx/sites-available/docker /etc/nginx/sites-enabled/

# Setup service (TODO)
sudo docker-gen -only-published -watch -notify /etc/docker-gen/update.sh /etc/docker-gen/nginx.tmpl /etc/nginx/sites-available/docker
```

## Additional software (Grav)

```
wget https://github.com/getgrav/grav/releases/download/1.6.9/grav-admin-v1.6.9.zip
sudo unzip grav-admin-v1.6.9.zip -d /etc/grav/
sudo chown -R www-data:www-data /etc/grav/grav-admin

sudo docker run -e VIRTUAL_HOST=ocean.gear.su -v /etc/grav/grav-admin:/var/www/html:cached -p 8000:80/tcp grav:latest
```

Add certificates to template:
```
certonly --standalone
```


https://tutorials.technology/tutorials/30-how-to-use-nginx-reverse-proxy-with-docker.html
https://blog.ippon.tech/set-up-a-reverse-proxy-nginx-and-docker-gen-bonus-lets-encrypt/
https://traefik.io/
https://chrissainty.com/how-i-dockerised-my-blog/
https://github.com/jwilder/nginx-proxy

