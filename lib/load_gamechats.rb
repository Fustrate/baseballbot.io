# frozen_string_literal: true

# This file really needs to be cleaned up, as does the entire /lib/ directory.

require 'pg'
require 'json'
require 'open-uri'
require 'chronic'
require 'mlb_gameday'

@attempts = 0
@failures = 0

@right_now = DateTime.now.strftime('%Y-%m-%d %H:%M:%S')

@api = MLBGameday::API.new

@conn = PG::Connection.new user: ENV['PG_USERNAME'],
                           dbname: ENV['PG_DATABASE'],
                           password: ENV['PG_PASSWORD']

URL = 'http://mlb.mlb.com/lookup/json/named.schedule_team_sponsors.bam?' \
      'start_date=\'%{start}\'&end_date=\'%{end}\'&team_id=%{team_id}&' \
      'season=%{year}&game_type=\'R\'&game_type=\'A\'&game_type=\'E\'&' \
      'game_type=\'F\'&game_type=\'D\'&game_type=\'L\'&game_type=\'W\'&' \
      'game_type=\'C\'&game_type=\'S\''

# Game types:
#   R: Regular Season
#   A: All Star Game
#   E: Exhibition
#   F: Wild Card Game
#   D: Divisional Series
#   L: League Championship Series
#   W: World Series
#   C: ???
#   S: Spring Training

def adjust_time_proc(post_at)
  if post_at =~ /\A\-?\d{1,2}\z/
    -> (time) { time + Regexp.last_match[0].to_i * 3600 }
  elsif post_at =~ /(1?[012]|\d)(:\d\d|) ?(am|pm)/i
    lambda do |time|
      hours = Regexp.last_match[1].to_i
      hours += 12 if hours != 12 && Regexp.last_match[3].casecmp('pm') == 0
      minutes = Regexp.last_match[1] || ':00'
      minutes = minutes[1..2].to_i

      Time.new(time.year, time.month, time.day, hours, minutes, 0)
    end
  else
    # Default to 3 hours before game time
    -> (time) { time - 3 * 3600 }
  end
end

def load_schedule(subreddit_id, code, post_at, start_date, end_date)
  team = @api.team code

  unless team
    puts "Invalid team code: #{code}"
    return
  end

  adjusted_time = adjust_time_proc post_at

  schedule_url = format(URL,
                        start: start_date.strftime('%Y/%m/%d'),
                        end: end_date.strftime('%Y/%m/%d'),
                        team_id: team.id,
                        year: start_date.year)

  data = JSON.parse open(schedule_url).read
  schedule = data['schedule_team_sponsors']['schedule_team_complete']
  games = schedule['queryResults']['row']

  games.each do |game|
    next if game['game_time_et'][11..15] == '03:33'

    gametime = Chronic.parse(game['game_time_et']) - 10_800
    post_at = adjusted_time.call(gametime)

    next if post_at < Time.now

    @attempts += 1

    begin
      @conn.exec_params(
        'INSERT INTO gamechats
        (gid, post_at, starts_at, status, created_at, updated_at, subreddit_id)
        VALUES
        ($1, $2, $3, $4, $5, $6, $7)',
        [
          game['game_id'].gsub(%r{[/\-]}, '_'),
          post_at.strftime('%Y-%m-%d %H:%M:%S'),
          gametime.strftime('%Y-%m-%d %H:%M:%S'),
          'Future',
          @right_now,
          @right_now,
          subreddit_id
        ]
      )
    rescue PG::UniqueViolation
      @failures += 1
    end
  end
end

if ARGV.count == 2
  month, year = ARGV[1].split(%r{[-/]}).map(&:to_i)
  names = ARGV[0].split(%r{[+/,]}).map(&:downcase)
elsif ARGV.count == 1
  if ARGV[0] =~ %r{(\d+)/(\d+)}
    _, month, year = Regexp.last_match.to_a
    names = []
  else
    month = Time.now.month
    year = Time.now.year
    names = ARGV[0].split(%r{[+/,]}).map(&:downcase)
  end
else
  raise 'Please pass 2 arguments: ruby load_schedule.rb mariners,dodgers 6/2015'
end

start_date = Chronic.parse "#{month}/1/#{year}"
end_date = Chronic.parse("#{month.to_i + 1}/1/#{year}") - 86_400

result = @conn.exec(
  "SELECT id, name, team_code, options#>>'{gamechats,post_at}' AS post_at
  FROM subreddits
  WHERE (options#>>'{gamechats,enabled}')::boolean IS TRUE"
)

result.each do |row|
  next unless names.empty? || names.include?(row['name'].downcase)

  load_schedule row['id'],
                row['team_code'],
                row['post_at'],
                start_date,
                end_date
end

puts "Added #{@attempts - @failures} of #{@attempts}"
