# frozen_string_literal: true
require_relative 'baseballbot'

@delete = %w(CHC-wagon SEA-wagon CHAOS-wagon).freeze

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

@bot.use_account('BaseballBot')
@subreddit = @bot.session.subreddit('baseball')

def load_flairs(after: nil)
  puts "Loading flairs#{after ? " after #{after}" : ''}"

  flairs = @subreddit.flair_listing(limit: 1000, after: after)

  flairs.each { |flair| process_flair(flair) }

  return unless flairs.after

  sleep 5

  load_flairs after: flairs.after
end

def process_flair(flair)
  return unless @delete.include? flair[:flair_css_class]

  puts "\tDeleting #{flair[:user]}'s flair " \
       "('#{flair[:flair_css_class]}', '#{flair[:flair_text]}')"

  @subreddit.delete_flair flair[:user]
end

load_flairs
