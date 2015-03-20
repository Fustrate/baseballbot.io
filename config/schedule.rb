set :output, '/home/baseballbot/apps/baseballbot.io/shared/log/whenever.log'

# every 2.minutes do
# end

# every 10.minutes do
# end

every 1.hour do
  command 'cd /home/baseballbot/apps/baseballbot.io/current/lib'
  command 'ruby update_sidebars.rb'
end
