# frozen_string_literal: true

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
