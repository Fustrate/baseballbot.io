# frozen_string_literal: true

set :output, '/home/baseballbot/apps/baseballbot.io/shared/log/whenever.log'

DIRECTORY = '/home/baseballbot/apps/baseballbot.io/current/lib'
BUNDLE_EXEC = 'bundle exec'

def step_minutes_by(step, except: [])
  every "#{(0.step(59, step).to_a - Array(except)).join(',')} * * * *" do
    yield
  end
end

every :minute do
  # command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby no_hitter_bot.rb"
end

every 1.hour do
  # command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby sidebars.rb update"
  command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby game_threads.rb off_day"
end

every 15.minutes do
  command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby check_messages.rb"
  command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby game_threads.rb pregame"
end

every 5.minutes do
  command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby game_threads.rb post"
end

# So we don't run twice on the hour
step_minutes_by(5, except: 0) do
  command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby sidebars.rb update baseball"
end

step_minutes_by(2, except: [0, 30]) do
  command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby game_threads.rb update"
end

step_minutes_by(30) do
  command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby game_threads.rb update posted"
end

every :saturday do
  # command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby load_game_threads.rb"
  # command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby load_sunday_game_threads.rb"
end

every 1.day, at: '5:30 am' do
  command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby around_the_horn.rb"
end
