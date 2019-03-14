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

module UnicornTasks
  def start!
    on_roles_in_sequence do
      return info('Unicorn is already running.') if running? && killable?

      with rails_env: fetch(:rails_env) do
        execute :bundle, :exec, :unicorn, options, fetch(:unicorn_rackup)
      end
    end
  end

  def stop!
    on_roles_in_sequence do
      return info('Unicorn is not running.') unless running?

      unless killable?
        info 'Cleaning up dead Unicorn pid...'
        execute :rm, fetch(:unicorn_pid)
      end

      kill(:QUIT, 'Stopping Unicorn...')
    end
  end

  def reload!
    invoke 'unicorn:start'

    on_roles_in_sequence { kill(:HUP, 'Reloading Unicorn') }
  end

  def restart!
    invoke 'unicorn:start'

    on_roles_in_sequence { kill(:USR2, 'Restarting Unicorn') }
  end

  def add_worker!
    on_roles_in_sequence { kill(:TTIN, 'Adding Unicorn worker') }
  end

  def remove_worker!
    on_roles_in_sequence { kill(:TTOU, 'Removing Unicorn worker') }
  end

  protected

  def on_roles_in_sequence
    on(roles(fetch(:unicorn_roles)), in: :sequence) do
      within current_path do
        yield
      end
    end
  end

  def kill(signal, message)
    info message

    execute :kill, "-s #{signal}", pid
  end

  def options
    [
      "-c #{fetch :unicorn_config_path}",
      "-E #{fetch :unicorn_rack_env}",
      '-D',
      fetch(:unicorn_options)
    ].compact.join(' ')
  end

  def pid
    "`cat #{fetch :unicorn_pid}`"
  end

  def pid_oldbin
    "`cat #{fetch :unicorn_pid}.oldbin`"
  end

  def running?
    test("[ -e #{fetch :unicorn_pid} ]")
  end

  def killable?
    test("kill -0 #{pid}")
  end
end

namespace :unicorn do
  desc 'Start Unicorn'
  task(:start) { UnicornTasks.start! }

  desc 'Stop Unicorn (QUIT)'
  task(:stop) { UnicornTasks.stop! }

  desc 'Reload Unicorn (HUP); use this when preload_app: false'
  task(:reload) { UnicornTasks.reload! }

  desc 'Restart Unicorn (USR2); use this when preload_app: true'
  task(:restart) { UnicornTasks.restart! }

  desc 'Duplicate Unicorn; alias of unicorn:restart'
  task(:duplicate) { UnicornTasks.restart! }

  desc 'Add a Unicorn worker (TTIN)'
  task(:add_worker) { UnicornTasks.add_worker! }

  desc 'Remove a Unicorn worker (TTOU)'
  task(:remove_worker) { UnicornTasks.remove_worker! }
end
