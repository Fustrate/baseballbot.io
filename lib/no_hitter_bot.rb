# frozen_string_literal: true

require_relative 'default_bot'

class NoHitterBot
  MIN_INNINGS = 6
  SUBREDDIT_NAME = 'baseball'
  TITLE_FORMAT = 'No-H****r Alert - %<pitcher_names>s ' \
                 '(%<pitching_team>s) vs. %<batting_team>s'

  # Depending on how far into a no-hit game we are, skip checks for a while
  WAIT_TIMES = [0, 3600, 1800, 900, 600, 300, 30].freeze

  def initialize
    @bot = DefaultBot.create(purpose: 'No Hitter Bot', account: 'BaseballBot')
  end

  def post_no_hitters!
    return unless perform_check?

    # Default to checking again in 30 minutes
    @next_check = [Time.now + 1800]

    schedule = @bot.api.schedule(
      date: Time.now.strftime('%m/%d/%Y'),
      hydrate: 'game,linescore,flags,team',
      sportId: 1
    )

    schedule.dig('dates', 0, 'games').each { |game| process_game(game) }

    @bot.redis.set 'next_no_hitter_check', @next_check.min.strftime('%F %T')
  end

  protected

  def perform_check?
    value = @bot.redis.get 'next_no_hitter_check'

    !value || Time.parse(value) < Time.now
  end

  def subreddit
    @subreddit ||= @bot.name_to_subreddit(SUBREDDIT_NAME)
  end

  def process_game(game)
    # return unless no_hitter?(game)

    inning = game.dig('linescore', 'currentInning')
    half = game.dig('linescore', 'inningHalf')

    # Game hasn't started yet
    return unless inning

    post_thread!(game, 'home') if post_home_thread?(game, inning, half)
    post_thread!(game, 'away') if post_away_thread?(game, inning, half)
  end

  def post_home_thread?(game, inning, half)
    return false if already_posted?(game['gamePk'], 'home')

    away_team_being_no_hit?(game, inning, half)
  end

  def post_away_thread?(game, inning, half)
    return false if already_posted?(game['gamePk'], 'away')

    home_team_being_no_hit?(game, inning, half)
  end

  # Checking for a perfect game is likely redundant
  def no_hitter?(game)
    # The flag doesn't get set until 6 innings are done
    return true if MIN_INNINGS < 6

    game.dig('flags', 'noHitter') || game.dig('flags', 'perfectGame')
  end

  # Check the away team if it's after the top of the target inning or later
  def away_team_being_no_hit?(game, inning, half)
    return unless game.dig('linescore', 'teams', 'away', 'hits').zero?

    if inning > MIN_INNINGS || (inning == MIN_INNINGS && half != 'Top')
      return true
    end

    @next_check << Time.now + WAIT_TIMES.last(MIN_INNINGS + 1)[inning]

    false
  end

  # Check the home team if it's the end of the target inning or later
  def home_team_being_no_hit?(game, inning, half)
    return unless game.dig('linescore', 'teams', 'home', 'hits').zero?

    if inning > MIN_INNINGS || (inning == MIN_INNINGS && half == 'End')
      return true
    end

    @next_check << Time.now + WAIT_TIMES.last(MIN_INNINGS + 1)[inning]

    false
  end

  def no_hitter_template(game, flag)
    Baseballbot::Template::NoHitter.new(
      title: TITLE_FORMAT,
      subreddit: subreddit,
      game_pk: game['gamePk'],
      flag: flag
    )
  end

  def post_thread!(game, flag)
    template = no_hitter_template(game, flag)

    submission = subreddit
      .submit title: template.title, text: template.evaluated_body

    insert_game_thread!(submission, game)

    submission.set_suggested_sort 'new'

    @bot.redis.hset(
      "#{SUBREDDIT_NAME}_no_hitters_#{game['gamePk']}",
      flag,
      submission.id
    )
  end

  def already_posted?(game_pk, flag)
    @bot.redis.hget("#{SUBREDDIT_NAME}_no_hitters_#{game_pk}", flag)
  end

  def insert_game_thread!(submission, game)
    data = [
      Time.now.strftime('%F %T'),
      subreddit.id,
      game['gamePk'],
      submission.id,
      submission.title
    ]

    @bot.db.exec_params(<<~SQL, data)
      INSERT INTO game_threads (
        post_at, starts_at, subreddit_id, game_pk, post_id, title, status, type
      )
      VALUES ($1, $1, $2, $3, $4, $5, 'Posted', 'no_hitter')
    SQL
  end
end

NoHitterBot.new.post_no_hitters!
