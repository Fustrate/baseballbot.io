# frozen_string_literal: true

namespace :zeitwerk do
  desc 'Make sure we don\'t run into a zeitwerk error on puma:restart'
  task :ensure_loadable do
    run_locally do
      info 'Ensuring app is loadable...'

      output = `rails zeitwerk:check`

      raise Capistrano::ValidationError, output unless output['All is good!']

      info 'All is good!'
    end
  end
end
