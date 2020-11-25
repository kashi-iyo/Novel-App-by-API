#!/bin/bash

# master.keyの環境変数を反映
source /etc/environment

# bundleコマンドを反映
source ~/.bash_profile

cd /var/www/rails/Novel-App-by-API

sudo chown -R ec2-user /var/www/rails/Novel-App-by-API

RAILS_ENV=production bundle
RAILS_ENV=production bundle exec rake db:create db:migrate
RAILS_ENV=production bundle exec rake assets:precompile