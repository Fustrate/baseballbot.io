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

@client = @bot.client
@bot.client.use_account('BaseballBot')

@subreddit = @bot.session.subreddit('baseball')

@counts = Hash.new { |h, k| h[k] = 0 }

def load_flairs(after: nil)
  puts "Loading flairs#{after ? " after #{after}" : ''}"

  flairs = @subreddit.flair_listing(limit: 1000, after: after)

  puts flairs.inspect

  # flairs.each do |flair|
  #   @counts[flair.flair_css_class] += 1
  # end
  #
  # if flairs.after
  #   sleep 5
  #
  #   load_flairs after: flairs.after
  # else
  #   puts @counts.inspect
  # end
end

load_flairs
