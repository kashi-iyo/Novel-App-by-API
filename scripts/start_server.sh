#!/bin/bash

# ec2-userへ所有権を渡す
sudo chown -R ec2-user /var/www/rails/Novel-App-by-API

# アプリのディレクトリへ移動
cd /var/www/rails/Novel-App-by-API

# Nginxの起動
sudo systemctl restart nginx

# bundleコマンドを反映
source ~/.bash_profile
# RAILS_MASTER_KEY反映
source etc/environment

bundler -v
echo $RAILS_MASTER_KEY

# Unicornの起動
bundle exec unicorn_rails -c /var/www/rails/Novel-App-by-API/config/unicorn.conf.rb -D -E production