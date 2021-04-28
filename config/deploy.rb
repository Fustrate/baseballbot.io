# frozen_string_literal: true

# config valid only for current version of Capistrano
lock '~> 3.13'

set :application, 'baseballbot.io'
set :user, 'baseballbot'
set :deploy_to, "/home/#{fetch :user}/apps/#{fetch :application}"

set :repo_url, 'git@github.com:Fustrate/baseballbot.io.git'
set :branch, ENV['REVISION'] || :master

append :linked_dirs, 'log', 'public/packs', 'public/system', 'tmp/cache', 'tmp/pids', 'tmp/sockets'

append :linked_files, 'config/database.yml', 'config/honeybadger.yml', 'config/master.key', 'config/reddit.yml',
       'config/skylight.yml'

set :default_env, path: '/opt/ruby/bin:$PATH'

set :rbenv_ruby, File.read(File.expand_path('../.ruby-version', __dir__)).strip
set :rbenv_prefix, "RBENV_ROOT=#{fetch :rbenv_path} #{fetch :rbenv_path}/bin/rbenv exec"
set :rbenv_map_bins, %w[bundle gem honeybadger puma rails rake ruby sidekiq sidekiqctl yarn]

set :sidekiq_config, 'config/sidekiq.yml'

namespace :deploy do
  before :compile_assets, 'webpacker:backup_manifest'
  after :finished, 'puma:phased-restart'
  after :finishing, :cleanup
end

namespace :puma do
  after :restart, 'sidekiq:restart'
  after :start, 'sidekiq:restart'
  after :'phased-restart', 'sidekiq:restart'
end
