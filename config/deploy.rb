# frozen_string_literal: true

# config valid only for current version of Capistrano
lock '3.11.1'

set :application, 'baseballbot.io'
set :user, 'baseballbot'

set :repo_url, 'git@github.com:Fustrate/baseballbot.io.git'
set :branch, ENV['REVISION'] || :master

set :deploy_to, "/home/#{fetch :user}/apps/#{fetch :application}"

set :linked_files, %w[
  config/database.yml config/honeybadger.yml config/master.key config/reddit.yml
  config/skylight.yml
]

set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets public/system]

set :default_env, path: '/opt/ruby/bin:$PATH'

set :rbenv_ruby, File.read(File.expand_path('../.ruby-version', __dir__)).strip
set :rbenv_prefix, "RBENV_ROOT=#{fetch :rbenv_path} " \
                   "#{fetch :rbenv_path}/bin/rbenv exec"
set :rbenv_map_bins,
    %w[bundle gem honeybadger rails rake ruby sidekiq sidekiqctl yarn]

set :sidekiq_config, 'config/sidekiq.yml'

namespace :deploy do
  after :publishing, 'unicorn:reload'
  after :finishing,  :cleanup

  # after :finishing, 'sidekiq:start'
end
