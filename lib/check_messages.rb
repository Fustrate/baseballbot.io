# frozen_string_literal: true
require_relative 'baseballbot'

GD2 = 'http://gd2.mlb.com/components/game/mlb'
SCOREBOARD = "#{GD2}/year_%Y/month_%m/day_%d/miniscoreboard.xml"

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
  user_agent: 'BaseballBot by /u/Fustrate - Messages'
)

TITLE = /(?:game ?(?:thread|chat|day)|gdt)/i
LINK = %r{(?:redd\.it|/comments|reddit\.com)/([a-z0-9]{6})}i
GID = /(?:gid_)?(\d{4}_\d{2}_\d{2}_[a-z]{6}_[a-z]{6}_\d)/

def client
  @bot.use_account('BaseballBot')

  @bot.client
end

def process_message(message)
  return unless message.subject =~ TITLE && message.body =~ LINK

  post_id = Regexp.last_match[1]

  submissions = client.from_fullname("t3_#{post_id}")

  return unless submissions

  submission = submissions.first

  subreddit = submission[:subreddit].downcase

  gid = if submission[:selftext] =~ GID
          Regexp.last_match[1]
        else
          find_possible_game(subreddit, post_id)
        end

  @bot.redis.hset gid, subreddit, post_id if gid

  message.mark_as_read
end

def find_possible_game(subreddit, post_id)
  gids = possible_games[Baseballbot.subreddit_to_code subreddit]
  possibilities = []

  # Remove GIDs that have already been sent to us
  gids.each do |gid|
    existing_id = @bot.redis.hget gid, subreddit

    # This post_id is already in the system, so make sure `first` returns nil
    if existing_id == post_id
      possibilities.unshift nil
      break
    end

    possibilities << gid unless existing_id
  end

  possibilities.first
end

def possible_games
  @possible_games ||= load_possible_games
end

def load_possible_games
  games = Hash.new { |h, k| h[k] = [] }

  Nokogiri::XML(open(Time.now.strftime(SCOREBOARD)))
          .xpath('//games/game')
          .map do |game|
            gid = game.xpath('@gameday_link').text

            games[game.xpath('@home_name_abbrev').text] << gid
            games[game.xpath('@away_name_abbrev').text] << gid
          end

  games
end

def unread_messages(client)
  client.my_messages('unread', false, limit: 5) || []
end

def check_messages(retry_on_failure: true)
  unread_messages(client).each { |msg| process_message msg }
rescue Redd::Error::ServiceUnavailable
  return unless retry_on_failure

  puts 'Service unavailable: waiting 30 seconds to retry.'

  sleep 30

  check_messages(retry_on_failure: false)
end

check_messages
