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

@client = @bot.clients['BaseballBot']
@access = @bot.accounts.select { |_, a| a.name == 'BaseballBot' }.values.first.access

@counts = Hash.new { |h, k| h[k] = 0 }

def load_flairs(after: nil)
  puts "Loading flairs#{after ? " after #{after}" : ''}"

  flairs = @subreddit.get_flairlist(limit: 1000, after: after)

  flairs.each do |flair|
    @counts[flair.flair_css_class] += 1
  end

  if flairs.after
    sleep 5

    load_flairs after: flairs.after
  else
    puts @counts.inspect
  end
end


@client.with(@access) do
  @subreddit = @client.subreddit_from_name('baseball')

  load_flairs
end

