# frozen_string_literal: true

set :output, '/home/baseballbot/apps/baseballbot.io/shared/log/whenever.log'

DIRECTORY = '/home/baseballbot/apps/baseballbot.io/current/lib'
BUNDLE_EXEC = 'bundle exec'

every 1.hour do
  command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby sidebars.rb update"
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
every '5,10,15,20,25,30,35,40,45,50,55 * * * *' do
  command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby sidebars.rb update baseball"
end

every 2.minutes do
  command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby game_threads.rb update"
end

every :saturday do
  command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby load_sunday_game_threads.rb"
end

every 1.day, at: '5:30 am' do
  command "cd #{DIRECTORY} && #{BUNDLE_EXEC} ruby around_the_horn.rb"
end
