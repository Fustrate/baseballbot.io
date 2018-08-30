# frozen_string_literal: true

require_relative 'default_bot'

class NoHitterBot
  MIN_INNINGS = 1
  SUBREDDIT_NAME = 'baseballtest'

  def initialize
    @bot = default_bot(purpose: 'No Hitter Bot', account: 'BaseballBot')
  end

  def run!
    data = @bot.api.schedule(
      date: Time.now.strftime('%m/%d/%Y'),
      hydrate: 'game(content(summary)),linescore,flags,team'
    )

    JSON.parse(data).dig('dates', 0, 'games').each do |game|
      process_game(game)
    end
  end

  protected

  def subreddit
    @subreddit ||= @bot.session.subreddit(SUBREDDIT_NAME)
  end

  def process_game(game)
    return unless no_hitter?(game)

    inning = game.dig('linescore', 'currentInning')
    half = game.dig('linescore', 'inningHalf')

    process_away_team(game, inning, half)
    process_home_team(game, inning, half)
  end

  # Checking for a perfect game is likely redundant
  def no_hitter?(game)
    game.dig('flags', 'noHitter') || game.dig('flags', 'perfectGame')
  end

  def process_away_team(game, inning, half)
    existing_id = @bot.redis.hget "no_hitter_#{game['gamePk']}", 'home'

    return update_thread!(existing_id, game, 'home') if existing_id

    post_thread!(game, 'home') if away_team_being_no_hit?(game, inning, half)
  end

  def process_home_team(game, inning, half)
    existing_id = @bot.redis.hget "no_hitter_#{game['gamePk']}", 'away'

    return update_thread!(existing_id, game, 'away') if existing_id

    post_thread!(game, 'away') if home_team_being_no_hit?(game, inning, half)
  end

  # Check the away team if it's after the top of the 6th or later
  def away_team_being_no_hit?(game, inning, half)
    return unless game.dig('linescore', 'teams', 'away').dig('hits').zero?

    inning > MIN_INNINGS || (inning == MIN_INNINGS && half != 'Top')
  end

  # Check the home team if it's the end of the 6th or later
  def home_team_being_no_hit?(game, inning, half)
    return unless game.dig('linescore', 'teams', 'home').dig('hits').zero?

    inning > MIN_INNINGS || (inning == MIN_INNINGS && half == 'End')
  end

  def post_thread!(game, flag)
    body, title = @subreddit.template_for('no_hitter')

    template = Baseballbot::Template::NoHitter.new(
      body: body,
      title: title,
      subreddit: @subreddit,
      game_pk: game['gamePk'],
      flag: flag
    )

    submission = @subreddit.submit(
      template.title,
      text: template.text,
      sendreplies: false
    )

    submission.set_suggested_sort 'new'

    @bot.redis.hset "no_hitter_#{game['gamePk']}", flag, submission.id
  end

  def update_thread!(post_id, game, flag)
    body, title = @subreddit.template_for('no_hitter_update')

    template = Baseballbot::Template::NoHitter.new(
      body: body,
      title: title,
      subreddit: @subreddit,
      game_pk: game['gamePk'],
      flag: flag
    )

    submission = @subreddit.load_submission(id: post_id)

    @subreddit.edit(
      id: post_id,
      body: template.replace_in(submission)
    )
  end
end

NoHitterBot.new.run!
