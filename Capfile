# frozen_string_literal: true

# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Include tasks from other gems
require 'capistrano/rbenv'
require 'capistrano/bundler'
# This needs to be required because... the gem is dumb?
require 'capistrano3-puma'
require 'capistrano/puma'
require 'capistrano/rails'
require 'capistrano/scm/git'
require 'capistrano/honeybadger'
require 'whenever/capistrano'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

install_plugin Capistrano::SCM::Git
install_plugin Capistrano::Puma
