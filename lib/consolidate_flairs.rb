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

@after = 't2_b5fby'

@bot.use_account('BaseballBot')
@subreddit = @bot.session.subreddit('baseball')

@changes = {
  'loser' => 'K-MLBmisc',
  'mlb' => 'MLB-MLBmisc',
  'sf verified' => 'sfg verified'
}

def load_flairs(after: nil)
  puts "Loading flairs#{after ? " after #{after}" : ''}"

  flairs = @subreddit.flair_listing(limit: 1000, after: after)

  flairs.each do |flair|
    next unless @changes[flair[:flair_css_class]]

    puts "\tChanging #{flair[:user]} from #{flair[:flair_css_class]} " \
         "to #{@changes[flair[:flair_css_class]]}"

    @subreddit.set_flair(
      Redd::Models::User.new(nil, name: flair[:user]),
      flair[:flair_text],
      css_class: @changes[flair[:flair_css_class]]
    )
  end

  return unless flairs.after

  sleep 5

  load_flairs after: flairs.after
end

load_flairs after: @after
