# frozen_string_literal: true
set :output, '/home/baseballbot/apps/baseballbot.io/shared/log/whenever.log'

every 1.hour do
  command 'cd /home/baseballbot/apps/baseballbot.io/current/lib && ' \
          'bundle exec ruby update_sidebars.rb'
end

every 15.minutes do
  command 'cd /home/baseballbot/apps/baseballbot.io/current/lib && ' \
          'bundle exec ruby check_messages.rb'

  command 'cd /home/baseballbot/apps/baseballbot.io/current/lib && ' \
          'bundle exec ruby post_pregames.rb'
end

every 5.minutes do
  command 'cd /home/baseballbot/apps/baseballbot.io/current/lib && ' \
          'bundle exec ruby post_gamechats.rb'
end

# So we don't run twice on the hour
every '5,10,15,20,25,30,35,40,45,50,55 * * * *' do
  command 'cd /home/baseballbot/apps/baseballbot.io/current/lib && ' \
          'bundle exec ruby update_sidebars.rb baseball'
end

every 2.minutes do
  command 'cd /home/baseballbot/apps/baseballbot.io/current/lib && ' \
          'bundle exec ruby update_gamechats.rb'
end
