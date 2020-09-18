#!/usr/bin/env puma

# frozen_string_literal: true

app_dir = '/home/baseballbot/apps/baseballbot.io'
shared_dir = "#{app_dir}/shared"

directory "#{app_dir}/current"
rackup "#{app_dir}/current/config.ru"
environment 'production'

tag 'puma-baseballbot'

pidfile "#{shared_dir}/tmp/pids/puma.pid"
state_path "#{shared_dir}/tmp/pids/puma.state"
stdout_redirect "#{shared_dir}/log/puma_access.log", "#{shared_dir}/log/puma_error.log", true

threads 1, 3

bind "unix://#{shared_dir}/tmp/sockets/puma.sock"

workers 0

restart_command 'bundle exec puma'

prune_bundler

on_restart do
  puts 'Refreshing Gemfile'

  ENV['BUNDLE_GEMFILE'] = ''
end
