# frozen_string_literal: true

# In order to make this work without needing a password, the following must be added using `visudo`:
#
#  baseballbot ALL=NOPASSWD: /bin/systemctl start puma-baseballbot
#  baseballbot ALL=NOPASSWD: /bin/systemctl restart puma-baseballbot
#  baseballbot ALL=NOPASSWD: /bin/systemctl stop puma-baseballbot
#  baseballbot ALL=NOPASSWD: /bin/systemctl kill -s SIGUSR1 puma-baseballbot

namespace :puma do
  %w[start restart stop].each do |command|
    desc "#{command} puma"
    task command do
      on roles(:app) do
        execute :sudo, :systemctl, command, 'puma-baseballbot'
      end
    end
  end

  desc 'phased-restart puma'
  task 'phased-restart' do
    on roles(:app) do
      execute :sudo, :systemctl, :kill, '-s SIGUSR1', 'puma-baseballbot'
    end
  end
end
