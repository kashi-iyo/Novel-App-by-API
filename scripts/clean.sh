#!/bin/bash

sudo systemctl stop nginx
kill -KILL -s QUIT `cat /var/www/rails/Novel-App-by-API/tmp/pids/unicorn.pid`
sudo rm -rf /var/www/rails/Novel-App-by-API