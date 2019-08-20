# frozen_string_literal: true

class TeamSchedule
  SCHEDULE_HYDRATION = 'team(venue(timezone)),game(content(summary)),' \
                       'linescore,broadcasts(all)'

  def initialize(bot:, subreddit:)
    @subreddit = subreddit
    @bot = bot
  end

  def games_between(start_date, end_date, team: nil)
    days = build_date_hash(start_date, end_date)

    calendar_dates(start_date, end_date, team: team).each do |calendar_date|
      calendar_date['games'].each do |game|
        next unless add_game_to_calendar?(game)

        # Rescheduled games, when converted to the local time zone,
        # end up in the previous day.
        date = adjusted_date(game['gameDate'].sub('03:33', '12:00'))

        days[date.strftime('%F')][:games] << process_game(game, date)
      end
    end

    days
  end

  protected

  def adjusted_date(date)
    Baseballbot::Utility.parse_time date, in_time_zone: @subreddit.timezone
  end

  def build_date_hash(start_date, end_date)
    days = {}

    start_date.upto(end_date).each do |day|
      days[day.strftime('%F')] = { date: day, games: [] }
    end

    days
  end

  def calendar_dates(start_date, end_date, team: nil)
    @bot.api.schedule(
      teamId: team || @subreddit.team.id,
      startDate: start_date.strftime('%m/%d/%Y'),
      endDate: end_date.strftime('%m/%d/%Y'),
      sportId: 1,
      eventTypes: 'primary',
      scheduleTypes: 'games',
      hydrate: SCHEDULE_HYDRATION
    ).dig('dates')
  end

  def add_game_to_calendar?(game)
    current_team_game?(game) && game['ifNecessary'] != 'Y' &&
      !game['rescheduleDate']
  end

  def current_team_game?(game)
    game.dig('teams', 'away', 'team', 'id') == @subreddit.team.id ||
      game.dig('teams', 'home', 'team', 'id') == @subreddit.team.id
  end

  def process_game(game, date)
    info = calendar_game_info(game, date)

    info[:over] = %w[F C D FT FR].include? info[:status_code]
    info[:outcome] = outcome(info) if info[:over]
    info[:status] = calendar_game_status info
    info[:result] = game_result(info)

    info
  end

  def calendar_game_info(game, date)
    {
      date: date,
      home: home_team?(game),
      opponent: game_opponent(game),
      score: calendar_game_score(game),
      tv: tv_stations(game),
      status_code: game['status']['statusCode'],
      game_pk: game['gamePk']
    }
  end

  def outcome(game)
    return 'Tied' if game[:score][0] == game[:score][1]

    game[:score][0] > game[:score][1] ? 'Won' : 'Lost'
  end

  def calendar_game_status(game)
    return 'Delayed' if game[:status_code].start_with? 'D'

    return "#{game[:outcome]} #{game[:score].join '-'}" if game[:over]

    return game[:date].strftime '%-I:%M' if game[:tv].empty?

    game[:date].strftime "%-I:%M, #{game[:tv]}"
  end

  def calendar_game_score(game)
    [
      game.dig('teams', flag(game), 'score'),
      game.dig('teams', opponent_flag(game), 'score')
    ]
  end

  def tv_stations(game)
    return '' unless game['broadcasts']

    flag = flag(game)

    game['broadcasts']
      .select { |broadcast| broadcast['type'] == 'TV' }
      .select { |broadcast| broadcast['language'] == 'en' }
      .select { |broadcast| broadcast['homeAway'] == flag }
      .map { |broadcast| broadcast['callSign'] }
      .join(', ')
  end

  def game_result(game)
    return '' unless game[:over]

    return 'T' if game[:score][0] == game[:score][1]

    game[:score][0] > game[:score][1] ? 'W' : 'L'
  end

  def game_opponent(game)
    @bot.api.team game.dig('teams', opponent_flag(game), 'team', 'id')
  end

  def home_team?(game)
    game.dig('teams', 'away', 'team', 'id') != @subreddit.team&.id
  end

  def flag(game)
    home_team?(game) ? 'home' : 'away'
  end

  def opponent_flag(game)
    home_team?(game) ? 'away' : 'home'
  end
end
