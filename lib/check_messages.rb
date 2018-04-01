# frozen_string_literal: true

require_relative 'default_bot'
require 'honeybadger/ruby'

GDX = 'http://gdx.mlb.com/components/game/mlb'
SCOREBOARD = "#{GDX}/year_%Y/month_%m/day_%d/miniscoreboard.xml"
TITLE = /(?:game ?(?:thread|chat|day)|gdt)/i
LINK = %r{(?:redd\.it|/comments|reddit\.com)/([a-z0-9]{6})}i
GID = /(?:gid_)?(\d{4}_\d{2}_\d{2}_[a-z]{6}_[a-z]{6}_\d)/

@bot = default_bot(purpose: 'Messages', account: 'BaseballBot')

def process_message(message)
  return unless message.subject =~ TITLE && message.body =~ LINK

  post_id = Regexp.last_match[1]

  submissions = @bot.session.from_ids("t3_#{post_id}")

  return unless submissions

  submission = submissions.first

  subreddit = submission.subreddit.display_name.downcase

  gid = if submission.selftext =~ GID
          Regexp.last_match[1]
        else
          find_possible_game(subreddit, post_id)
        end

  @bot.redis.hset gid, subreddit, post_id if gid

  message.mark_as_read
end

def subreddit_to_code(name)
  BaseballBot::Subreddits::DEFAULT_SUBREDDITS
    .find { |_, subreddit| subreddit.casecmp(name).zero? }[0]
end

def find_possible_game(subreddit, post_id)
  gids = possible_games[subreddit_to_code(subreddit)]
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

  Nokogiri::XML(URI.parse(Time.now.strftime(SCOREBOARD)).open)
    .xpath('//games/game')
    .map do |game|
      gid = game.xpath('@gameday_link').text

      games[game.xpath('@home_name_abbrev').text] << gid
      games[game.xpath('@away_name_abbrev').text] << gid
    end

  games
end

def unread_messages
  @bot.session.my_messages(category: 'unread', mark: false, limit: 5) || []
end

def check_messages(retry_on_failure: true)
  unread_messages.each { |msg| process_message msg }
rescue Redd::APIError
  return unless retry_on_failure

  puts 'Service unavailable: waiting 30 seconds to retry.'

  sleep 30

  check_messages(retry_on_failure: false)
rescue => ex
  Honeybadger.notify(ex, context: { team: team })
end

check_messages
