# frozen_string_literal: true

namespace :deploy do
  desc 'Run rake yarn:install'
  task :yarn_install do
    on roles(:web) do
      within(release_path) { execute(:yarn, :install) }
    end
  end
end
