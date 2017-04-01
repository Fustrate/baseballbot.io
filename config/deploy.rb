# frozen_string_literal: true

# config valid only for current version of Capistrano
lock '3.8.0'

set :application, 'baseballbot.io'
set :user, 'baseballbot'

set :repo_url, 'git@github.com:Fustrate/baseballbot.io.git'
set :branch, ENV['REVISION'] || :master

set :deploy_to, "/home/#{fetch :user}/apps/#{fetch :application}"

set :linked_files, %w(config/secrets.yml config/database.yml
                      config/honeybadger.yml config/skylight.yml)
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets public/system)

set :default_env, path: '/opt/ruby/bin:$PATH'

set :rbenv_ruby,
    File.read(File.expand_path('../../.ruby-version', __FILE__)).strip
set :rbenv_prefix, "RBENV_ROOT=#{fetch :rbenv_path} " \
                   "#{fetch :rbenv_path}/bin/rbenv exec"
set :rbenv_map_bins, %w(rake gem bundle ruby rails honeybadger)

namespace :deploy do
  after :publishing, 'unicorn:reload'
  after :finishing,  :cleanup
end
