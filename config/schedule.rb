# frozen_string_literal: true

set :output, '/home/baseballbot/apps/baseballbot.io/shared/log/whenever.log'

DIRECTORY = '/home/baseballbot/apps/baseballbot.io/current/lib'
BUNDLE_EXEC = 'bundle exec'

def step_minutes_by(step, except: [])
  every "#{(0.step(59, step).to_a - Array(except)).join(',')} * * * *" do
    yield
  end
end

def bundle_exec_ruby(name, *arguments)
  command(
    "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby #{name}.rb #{arguments.join(' ')}"
  )
end

every :minute do
  # bundle_exec_ruby :no_hitter_bot
  bundle_exec_ruby :mod_queue_slack
end

every 1.hour do
  bundle_exec_ruby :sidebars, :update
  bundle_exec_ruby :game_threads, :off_day
end

every 15.minutes do
  bundle_exec_ruby :check_messages
  # bundle_exec_ruby :game_threads, :pregame
end

every 5.minutes do
  # bundle_exec_ruby :game_threads, :post
end

# So we don't run twice on the hour
step_minutes_by(5, except: 0) do
  bundle_exec_ruby :sidebars, :update, :baseball
end

step_minutes_by(2, except: [0, 30]) do
  # bundle_exec_ruby :game_threads, :update
end

step_minutes_by(30) do
  # bundle_exec_ruby :game_threads, :update, :posted
end

every :saturday do
  # bundle_exec_ruby :load_game_threads
  # bundle_exec_ruby :load_sunday_game_threads
end

# This is off by an hour. Investigate 5 years from now.
every 1.day, at: '4:30 am' do
  bundle_exec_ruby :around_the_horn
end
