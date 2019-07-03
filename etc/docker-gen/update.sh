#!/bin/bash

systemctl stop nginx
grep -e "# HOST: .*$" /etc/nginx/sites-available/docker | sed "s/# HOST: //" | xargs -L1 certbot certonly --standalone -q -d
systemctl start nginx
