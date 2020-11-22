#!/bin/bash
cd /var/www/rails/Novel-App-by-API
bundle exec rake db:migrate RAILS_ENV=production
bundle exec rake assets:precompile RAILS_ENV=production