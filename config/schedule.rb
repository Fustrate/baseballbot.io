set :output, '/home/baseballbot/apps/baseballbot.io/shared/log/whenever.log'

every 1.hour do
  command 'cd /home/baseballbot/apps/baseballbot.io/current/lib && ' \
          'bundle exec ruby update_sidebars.rb'
end

every 10.minutes do
  command 'cd /home/baseballbot/apps/baseballbot.io/current/lib && ' \
          'bundle exec ruby post_gamechats.rb'
end

every 2.minutes do
  command 'cd /home/baseballbot/apps/baseballbot.io/current/lib && ' \
          'bundle exec ruby update_gamechats.rb'
end
