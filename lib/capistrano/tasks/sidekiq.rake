# frozen_string_literal: true

# In order to make this work without needing a password, the following must be added using `visudo`:
#
#  baseballbot ALL=NOPASSWD: /bin/systemctl restart sidekiq-baseballbot

# Sidekiq 6
namespace :sidekiq do
  task :restart do
    on roles(:app) do
      within release_path do
        execute :sudo, '/bin/systemctl', :restart, 'sidekiq-baseballbot'
      end
    end
  end
end
