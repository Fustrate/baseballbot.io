# frozen_string_literal: true

require_relative 'default_bot'

class NoHitterBot
  MIN_INNINGS = 1
  SUBREDDIT_NAME = 'baseballtest'
  HYDRATE = 'game(content(summary)),linescore,flags,team'

  def initialize
    @bot = default_bot(purpose: 'No Hitter Bot', account: 'BaseballBot')
  end

  def post_no_hitters!
    return unless perform_check?

    # Default to checking again in 10 minutes
    @next_check = [Time.now + 600]

    schedule = @bot.api.schedule(
      date: Time.now.strftime('%m/%d/%Y'),
      hydrate: HYDRATE
    )

    JSON.parse(schedule).dig('dates', 0, 'games')
      .each { |game| process_game(game) }
  end

  def update_no_hitters!
    @bot.redis.keys('no_hitter_*').each do |key|
      game_pk = key[10..-1]

      @bot.redis.hgetall(key) do |flag, post_id|
        game = @bot.api.schedule(gamePk: game_pk, hydrate: HYDRATE)
          .dig('dates', 0, 'games', 0)

        update_thread!(post_id, game, flag)
      end
    end
  end

  protected

  def perform_check?
    @bot.redis.get('next_no_hitter_check') do |value|
      !value || Time.parse(value) < Time.now
    end
  end

  def update_next_check_time!(new_time)
    @bot.redis.set 'next_no_hitter_check', new_time.strftime('%F %T')
  end

  def subreddit
    @subreddit ||= @bot.session.subreddit(SUBREDDIT_NAME)
  end

  def process_game(game)
    return unless no_hitter?(game)

    inning = game.dig('linescore', 'currentInning')
    half = game.dig('linescore', 'inningHalf')

    # Game hasn't started yet
    return unless inning

    post_thread!(game, 'home') if away_team_being_no_hit?(game, inning, half)
    post_thread!(game, 'away') if home_team_being_no_hit?(game, inning, half)
  end

  # Checking for a perfect game is likely redundant
  def no_hitter?(game)
    game.dig('flags', 'noHitter') || game.dig('flags', 'perfectGame')
  end

  # Check the away team if it's after the top of the target inning or later
  def away_team_being_no_hit?(game, inning, half)
    return unless game.dig('linescore', 'teams', 'away', 'hits').zero?

    if inning > MIN_INNINGS || (inning == MIN_INNINGS && half != 'Top')
      return true
    end

    wait_for [0, 3600, 3600, 1800, 1200, 600, 30].last(MIN_INNINGS + 1)[inning]

    false
  end

  # Check the home team if it's the end of the target inning or later
  def home_team_being_no_hit?(game, inning, half)
    return unless game.dig('linescore', 'teams', 'home', 'hits').zero?

    if inning > MIN_INNINGS || (inning == MIN_INNINGS && half == 'End')
      return true
    end

    wait_for [0, 3600, 3600, 1800, 1200, 600, 30].last(MIN_INNINGS + 1)[inning]

    false
  end

  def wait_for(seconds)
    @next_check << Time.now + seconds
  end

  def post_thread!(game, flag)
    template = Baseballbot::Template::NoHitter.new(
      body: @subreddit.template_for('no_hitter'),
      title: 'No-H****r Alert - %{pitcher_names} (%{pitching_team})',
      subreddit: @subreddit,
      game_pk: game['gamePk'],
      flag: flag
    )

    submission = @subreddit.submit(
      template.title,
      text: template.text,
      sendreplies: false
    )

    @bot.redis.hdel "no_hitter_#{game['gamePk']}", flag if template.final?

    submission.set_suggested_sort 'new'

    @bot.redis.hset "no_hitter_#{game['gamePk']}", flag, submission.id
  end

  def update_thread!(post_id, game, flag)
    submission = @subreddit.load_submission(id: post_id)

    template = Baseballbot::Template::NoHitter.new(
      body: @subreddit.template_for('no_hitter_update'),
      subreddit: @subreddit,
      game_pk: game['gamePk'],
      flag: flag,
      post_id: post_id
    )

    # Stop updating if the game is over
    if template.final? || template.postponed?
      @bot.redis.hdel "no_hitter_#{game['gamePk']}", flag
    end

    @subreddit.edit id: post_id, body: template.replace_in(submission)
  end
end

@no_hitter_bot = NoHitterBot.new

case ARGV[0]
when 'post'
  @no_hitter_bot.post_no_hitters!
when 'update'
  @no_hitter_bot.update_no_hitters!
end
