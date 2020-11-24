#!/bin/bash

str1="データベース名"

source /etc/environment
source ~/.bash_profile

echo $str1$DB_NAME
cd /var/www/rails/Novel-App-by-API
bundle -v

# RAILS_ENV=production bundle
# RAILS_ENV=production bundle exec rake db:migrate
# RAILS_ENV=production bundle exec rake assets:precompile