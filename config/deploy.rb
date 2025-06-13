# frozen_string_literal: true

lock '~> 3.15'

set :application, 'baseballbot.io'
set :user, 'baseballbot'
set :deploy_to, "/home/#{fetch :user}/apps/#{fetch :application}"

set :repo_url, 'git@github.com:Fustrate/baseballbot.io.git'
set :branch, ENV.fetch('REVISION', 'master')

append :linked_dirs, 'log', 'public/system', 'tmp/cache', 'tmp/pids', 'tmp/sockets', '.yarn/cache'

append :linked_files, 'config/database.yml', 'config/honeybadger.yml', 'config/credentials/production.key'

set :default_env, path: '/opt/ruby/bin:$PATH'

set :rbenv_ruby, File.read(File.expand_path('../.ruby-version', __dir__)).strip
set :rbenv_prefix, "RBENV_ROOT=#{fetch :rbenv_path} #{fetch :rbenv_path}/bin/rbenv exec"
set :rbenv_map_bins, %w[bundle gem honeybadger puma rails rake ruby yarn]

# capistrano-rails hasn't been updated to support propshaft's manifest filename
set :assets_manifests, -> { [release_path.join('public', fetch(:assets_prefix), '.manifest.json')] }

namespace :deploy do
  before :starting, 'zeitwerk:ensure_loadable'

  after :cleanup, 'assets:demolish'

  after :finished, 'puma:phased-restart'
end
