#!/bin/bash
# sudo systemctl restart nginx
cd /var/www/rails/Novel-App-by-API
sudo systemctl restart nginx
bundle exec unicorn_rails -c /var/www/rails/Novel-App-by-API/config/unicorn.conf.rb -D -E production