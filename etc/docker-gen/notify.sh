#!/bin/bash

systemctl stop nginx
grep -e "# HOST: .*$" /etc/nginx/conf.d/docker.conf | sed "s/# HOST: //" | xargs -L1 certbot certonly --standalone -q -d
systemctl start nginx
