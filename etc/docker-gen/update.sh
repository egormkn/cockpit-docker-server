#!/bin/bash

systemctl stop nginx
grep -e "# HOST: .*$" test.txt | sed "s/# HOST: //" | xargs -L1 certbot certonly --standalone -q -d
systemctl start nginx
