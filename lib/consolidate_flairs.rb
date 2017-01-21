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
@client = @bot.clients['BaseballBot']
@access = @bot.accounts.select { |_, a| a.name == 'BaseballBot' }.values.first.access

@changes = {
  'loser' => 'K-MLBmisc',
  'mlb' => 'MLB-MLBmisc',
  'sf verified' => 'sfg verified'
}

def load_flairs(after: nil)
  puts "Loading flairs#{after ? " after #{after}" : ''}"

  flairs = @subreddit.get_flairlist(limit: 1000, after: after)

  flairs.each do |flair|
    next unless @changes[flair.flair_css_class]
    
    puts "\tChanging #{flair.user} from #{flair.flair_css_class} to #{@changes[flair.flair_css_class]}"
    @subreddit.set_flair(flair.user, :user, flair.flair_text, @changes[flair.flair_css_class])
  end

  if flairs.after
    sleep 5

    load_flairs after: flairs.after
  end
end


@client.with(@access) do
  @subreddit = @client.subreddit_from_name('baseball')

  load_flairs after: @after
end

