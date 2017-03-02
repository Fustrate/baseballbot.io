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
@access = @bot.accounts
              .select { |_, a| a.name == 'BaseballBot' }
              .values
              .first
              .access

@remove_flairs = %w(NYY-wagon HOU-wagon)

def load_flairs(after: nil)
  puts "Loading flairs#{after ? " after #{after}" : ''}"

  flairs = @subreddit.get_flairlist(limit: 1000, after: after)

  flairs.each do |flair|
    next unless @remove_flairs.include?(flair.flair_css_class)

    puts "\tChanging #{flair.user} from #{flair.flair_css_class} to CHAOS"
    @subreddit.set_flair(flair.user, :user, 'Team Chaos', 'CHAOS-wagon')
  end

  return unless flairs.after

  sleep 5

  load_flairs after: flairs.after
end

@client.with(@access) do
  @subreddit = @client.subreddit_from_name('baseball')

  load_flairs after: 't2_cordb'
end
