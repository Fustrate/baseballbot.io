# frozen_string_literal: true

module Sidekiq
  module RakeTasks
    def start
      puts 'Starting sidekiq...'

      start_sidekiq!
    end

    def stop
      unless File.exist?(sidekiq_pid_file)
        puts "Sidekiq PID file (#{sidekiq_pid_file}) not found."
        return
      end

      pid = File.each_line(sidekiq_pid_file).first.strip

      puts "Stopping sidekiq (#{pid})..."

      stop_sidekiq!
    end

    def start_sidekiq!
      line = Terrapin::CommandLine.new 'bundle', 'exec sidekiq -C :config -e :env --daemon --logfile :log -P :pid'

      puts line.run(
        config: 'config/sidekiq.yml',
        env: ::Rails.env,
        log: 'log/sidekiq.log',
        pid: sidekiq_pid_file
      )
    end

    def stop_sidekiq!
      line = Terrapin::CommandLine.new('sidekiqctl', 'stop :pidfile')

      puts line.run(pidfile: sidekiq_pid_file)
    end

    def sidekiq_pid_file
      @sidekiq_pid_file ||= ::Rails.root.join('tmp', 'pids', 'sidekiq.pid')
    end
  end
end

namespace :sidekiq do
  desc 'Start Sidekiq'
  task :start do
    Sidekiq::RakeTasks.start
  end

  desc 'Stop Sidekiq'
  task :stop do
    Sidekiq::RakeTasks.stop
  end

  desc 'Restart Sidekiq'
  task :restart do
    Rake::Task['sidekiq:stop'].invoke
    Rake::Task['sidekiq:start'].invoke
  end
end
