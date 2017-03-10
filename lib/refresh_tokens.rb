# frozen_string_literal: true
require_relative 'baseballbot'

@bot = Baseballbot.new(
  reddit: {
    user_agent: 'Baseballbot by /u/Fustrate',
    client_id: ENV['REDDIT_CLIENT_ID'],
    secret: ENV['REDDIT_SECRET'],
    redirect_uri: ENV['REDDIT_REDIRECT_URI']
  },
  db: {
    user: ENV['PG_USERNAME'],
    dbname: ENV['PG_DATABASE'],
    password: ENV['PG_PASSWORD']
  },
  user_agent: 'BaseballBot by /u/Fustrate - Flairs'
)

@bot.accounts.each do |_, account|
  unless account.access.expired?
    puts "Skipping #{account.name}"

    next
  end

  begin
    puts "Refreshing #{account.name}"

    @bot.use_account account.name
  rescue Redd::APIError => e
    puts "\tError: #{e.class}"
  end

  sleep 5
end
