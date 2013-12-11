#!/bin/bash
su postgres --command "pg_ctl -D /postgres start" &
cd /luxhaven
/.gem/ruby/2.0.0/bin/bundle install
/.gem/ruby/2.0.0/bin/bundle exec rake db:migrate
/.gem/ruby/2.0.0/bin/bundle exec puma -p 3000