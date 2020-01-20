# frozen_string_literal: true

require_relative 'default_bot'

class CheckMessages
  TITLE = /(?:game ?(?:thread|chat|day)|gdt)/i.freeze
  LINK = %r{(?:redd\.it|/comments|reddit\.com)/([a-z0-9]{6})}i.freeze
  GID = /(?:gid_)?(\d{4}_\d{2}_\d{2}_[a-z]{6}_[a-z]{6}_\d)/.freeze

  def initialize
    @bot = DefaultBot.create(purpose: 'Messages', account: 'BaseballBot')
  end

  def run!(retry_on_failure: true)
    unread_messages.each { |message| process_message message }
  rescue Redd::APIError
    return unless retry_on_failure

    puts 'Service unavailable: waiting 30 seconds to retry.'

    sleep 30

    run!(retry_on_failure: false)
  rescue => e
    Honeybadger.notify(e)
  end

  protected

  def unread_messages
    @bot.session.my_messages(category: 'unread', mark: false, limit: 10) || []
  end

  def process_message(message)
    return unless message.subject =~ TITLE && message.body =~ LINK

    post_id = Regexp.last_match[1]

    submission = @bot.session.from_ids("t3_#{post_id}")&.first

    return unless submission

    subreddit = submission.subreddit.display_name.downcase

    gid = gid_for_submission(submission, subreddit, post_id)

    @bot.redis.hset gid, subreddit, post_id if gid

    message.mark_as_read
  end

  def gid_for_submission(submission, subreddit, post_id)
    return Regexp.last_match[1] if submission.selftext =~ GID

    find_possible_game(subreddit, post_id)
  end

  def subreddit_to_code(name)
    Baseballbot::Subreddits::DEFAULT_SUBREDDITS
      .find { |_, subreddit| subreddit.casecmp(name).zero? }[0]
  end

  def find_possible_game(subreddit, post_id)
    gids = possible_games[subreddit_to_code(subreddit)]
    possibilities = []

    # Remove GIDs that have already been sent to us
    gids.each do |gid|
      existing_id = @bot.redis.hget gid, subreddit

      # This post_id is already in the system
      return nil if existing_id == post_id

      possibilities << gid unless existing_id
    end

    possibilities.first
  end

  def possible_games
    @possible_games ||= load_possible_games
  end

  def load_possible_games
    games = Hash.new { |h, k| h[k] = [] }

    todays_games.each do |game|
      gid = gid_for_game(game)

      games[game.dig('teams', 'away', 'team', 'abbreviation')] << gid
      games[game.dig('teams', 'home', 'team', 'abbreviation')] << gid
    end

    games
  end

  def todays_games
    @bot.api.schedule(
      sportId: 1,
      date: Time.now.strftime('%m/%d/%Y'),
      hydrate: 'game(content(summary)),linescore,flags,team'
    ).dig('dates', 0, 'games') || []
  end

  # This is no longer included in the data - we might have to switch to
  # using game_pk instead.
  def gid_for_game(game)
    format(
      '%<date>s_%<away>smlb_%<home>smlb_%<number>d',
      date: Time.now.strftime('%Y_%m_%d'),
      away: game.dig('teams', 'away', 'team', 'teamCode'),
      home: game.dig('teams', 'home', 'team', 'teamCode'),
      number: game['gameNumber'].to_i
    )
  end
end

CheckMessages.new.run!
