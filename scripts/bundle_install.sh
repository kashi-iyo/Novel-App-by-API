#!/bin/bash

pwd
cat /etc/environment
source /etc/environment
echo `データベース名: $DB_NAME`
cd /var/www/rails/Novel-App-by-API
pwd
echo $DB_NAME
# source etc/environment
# RAILS_ENV=production bundle
# RAILS_ENV=production bundle exec rake db:migrate
# RAILS_ENV=production bundle exec rake assets:precompile