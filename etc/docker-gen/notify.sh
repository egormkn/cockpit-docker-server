#!/bin/bash

grep -e "# HOST: .*$" /etc/nginx/conf.d/docker.conf | sed "s/# HOST: //" | xargs -L1 certbot run --nginx --redirect -q -d
nginx -s reload