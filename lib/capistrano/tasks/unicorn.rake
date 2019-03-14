# frozen_string_literal: true

namespace :load do
  task :defaults do
    set :unicorn_roles, :app
    set :unicorn_options, nil
    set :unicorn_rackup, -> { "#{current_path}/config.ru" }
    set :unicorn_restart_sleep_time, 3
    set :unicorn_rack_env, 'deployment'
    set :unicorn_pid, -> { "#{current_path}/tmp/pids/unicorn.pid" }
    set :unicorn_config_path,
        -> { "#{current_path}/config/unicorn/#{fetch(:stage)}.rb" }
  end
end

namespace :unicorn do
  desc 'Start Unicorn'
  task :start do
    on(roles(fetch(:unicorn_roles)), in: :sequence) do
      within current_path do
        if test("[ -e #{fetch :unicorn_pid} ] && kill -0 #{pid}")
          info 'Unicorn is already running...'
        else
          with rails_env: fetch(:rails_env) do
            options = [
              "-c #{fetch :unicorn_config_path}",
              "-E #{fetch :unicorn_rack_env}",
              '-D',
              fetch(:unicorn_options)
            ]

            execute :bundle, :exec, :unicorn,
                    options.compact.join(' '),
                    fetch(:unicorn_rackup)
          end
        end
      end
    end
  end

  desc 'Stop Unicorn (QUIT)'
  task :stop do
    on(roles(fetch(:unicorn_roles)), in: :sequence) do
      within current_path do
        if test("[ -e #{fetch :unicorn_pid} ]")
          if test("kill -0 #{pid}")
            info 'Stopping Unicorn...'
            execute :kill, '-s QUIT', pid
          else
            info 'Cleaning up dead Unicorn pid...'
            execute :rm, fetch(:unicorn_pid)
          end
        else
          info 'Unicorn is not running...'
        end
      end
    end
  end

  desc 'Reload Unicorn (HUP); use this when preload_app: false'
  task :reload do
    invoke 'unicorn:start'

    on(roles(fetch(:unicorn_roles)), in: :sequence) do
      within current_path do
        info 'Reloading Unicorn'
        execute :kill, '-s HUP', pid
      end
    end
  end

  desc 'Restart Unicorn (USR2); use this when preload_app: true'
  task :restart do
    invoke 'unicorn:start'

    on(roles(fetch(:unicorn_roles)), in: :sequence) do
      within current_path do
        info 'Restarting Unicorn'
        execute :kill, '-s USR2', pid
      end
    end
  end

  desc 'Duplicate Unicorn; alias of unicorn:restart'
  task :duplicate do
    invoke 'unicorn:restart'
  end

  desc 'Add a Unicorn worker (TTIN)'
  task :add_worker do
    on(roles(fetch(:unicorn_roles)), in: :sequence) do
      within current_path do
        info 'Adding Unicorn worker'
        execute :kill, '-s TTIN', pid
      end
    end
  end

  desc 'Remove a Unicorn worker (TTOU)'
  task :remove_worker do
    on(roles(fetch(:unicorn_roles)), in: :sequence) do
      within current_path do
        info 'Removing Unicorn worker'
        execute :kill, '-s TTOU', pid
      end
    end
  end
end

def pid
  "`cat #{fetch :unicorn_pid}`"
end

def pid_oldbin
  "`cat #{fetch :unicorn_pid}.oldbin`"
end
