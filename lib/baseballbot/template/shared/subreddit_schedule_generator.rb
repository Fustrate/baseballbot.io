# frozen_string_literal: true

class SubredditScheduleGenerator
  def initialize(api:, subreddit:)
    @subreddit = subreddit
    @api = api
  end

  def games_between(start_date, end_date, team: nil)
    SubredditSchedule.new(
      api: @api,
      subreddit: @subreddit,
      team_id: team || @subreddit.team&.id
    ).generate(start_date, end_date)
  end
end

# This allows us to generate a schedule for a team other than the one belonging
# to the subreddit.
class SubredditSchedule
  SCHEDULE_HYDRATION = [
    'team(venue(timezone))',
    'game(content(summary))',
    'linescore',
    'broadcasts(all)'
  ].join(',').freeze

  def initialize(api:, subreddit:, team_id:)
    @api = api
    @subreddit = subreddit
    @team_id = team_id
  end

  def generate(start_date, end_date)
    days = build_date_hash(start_date, end_date)

    calendar_dates(start_date, end_date).each do |calendar_date|
      calendar_date['games'].each do |data|
        date = adjust_game_time(data['gameDate'])

        game = team_calendar_game(data: data, date: date)

        days[date.strftime('%F')][:games] << game if game.visible?
      end
    end

    days
  end

  protected

  # Rescheduled games, when converted to the local time zone, end up in the
  # previous day.
  def adjust_game_time(timestamp)
    Baseballbot::Utility.parse_time(
      timestamp.sub('03:33', '12:00'),
      in_time_zone: @subreddit.timezone
    )
  end

  def build_date_hash(start_date, end_date)
    days = {}

    start_date.upto(end_date).each do |day|
      days[day.strftime('%F')] = { date: day, games: [] }
    end

    days
  end

  def calendar_dates(start_date, end_date)
    @api.schedule(
      teamId: @team_id,
      startDate: start_date.strftime('%m/%d/%Y'),
      endDate: end_date.strftime('%m/%d/%Y'),
      sportId: 1,
      eventTypes: 'primary',
      scheduleTypes: 'games',
      hydrate: SCHEDULE_HYDRATION
    ).dig('dates')
  end

  def team_calendar_game(data:, date:)
    TeamCalendarGame.new(
      api: @api,
      data: data,
      team_id: @team_id,
      date: date
    )
  end
end

class TeamCalendarGame
  attr_reader :flag, :opponent_flag, :team_id, :game_pk, :date

  def initialize(api:, data:, team_id:, date:)
    @api = api
    @data = data
    @team_id = team_id
    @date = date

    @flag, @opponent_flag = home_team? ? %w[home away] : %w[away home]
    @game_pk = data['gamePk']
  end

  def home_team?
    @home_team ||= @data.dig('teams', 'away', 'team', 'id') != @team_id
  end

  def opponent
    @opponent ||= @api.team(@data.dig('teams', opponent_flag, 'team', 'id'))
  end

  def over?
    @over ||= %w[F C D FT FR].include?(@data['status']['statusCode'])
  end

  def outcome
    return unless over?

    return 'Tied' if score[0] == score[1]

    score[0] > score[1] ? 'Won' : 'Lost'
  end

  def score
    @score ||= [
      @data.dig('teams', flag, 'score'),
      @data.dig('teams', opponent_flag, 'score')
    ]
  end

  def status
    return 'Delayed' if @data['status']['statusCode'].start_with? 'D'

    return "#{outcome} #{score.join '-'}" if over?

    [
      @date.strftime('%-I:%M'),
      tv_stations
    ].reject(&:empty?).join(', ')
  end

  def tv_stations
    return '' unless @data['broadcasts']

    @tv_stations ||= @data['broadcasts']
      .select { |broadcast| broadcast['type'] == 'TV' }
      .select { |broadcast| broadcast['language'] == 'en' }
      .select { |broadcast| broadcast['homeAway'] == flag }
      .map { |broadcast| broadcast['callSign'] }
      .join(', ')
  end

  def wlt
    return '' unless over?

    return 'T' if score[0] == score[1]

    score[0] > score[1] ? 'W' : 'L'
  end

  def visible?
    current_team_game? && @data['ifNecessary'] != 'Y' &&
      !@data['rescheduleDate']
  end

  protected

  def current_team_game?
    [
      @data.dig('teams', 'away', 'team', 'id'),
      @data.dig('teams', 'home', 'team', 'id')
    ].include?(@team_id)
  end
end
