# frozen_string_literal: true

require_relative 'markdown_calendar'
require_relative 'subreddit_schedule_generator'

class Baseballbot
  module Template
    class Shared
      module Calendar
        def month_calendar(downcase: false)
          start_date = Date.civil(Date.today.year, Date.today.month, 1)
          end_date = Date.civil(Date.today.year, Date.today.month, -1)

          dates = team_schedule.games_between(start_date, end_date)

          cells = dates.map do |_, day|
            cell(day[:date].day, day[:games], downcase: downcase)
          end

          MarkdownCalendar.generate(cells, dates)
        end

        def month_games
          start_date = Date.civil(Date.today.year, Date.today.month, 1)
          end_date = Date.civil(Date.today.year, Date.today.month, -1)

          team_schedule.games_between(start_date, end_date)
            .flat_map { |_, day| day[:games] }
        end

        def previous_games(limit, team: nil)
          team_id = team || @subreddit.team.id

          games = []
          start_date = Date.today - limit - 7

          # Go backwards an extra week to account for off days
          team_schedule.games_between(start_date, Date.today, team: team_id)
            .values
            .reverse_each do |day|
              next if day[:date] > Date.today

              games.concat day[:games].keep_if(&:over?)

              break if games.count >= limit
            end

          games.first(limit)
        end

        def upcoming_games(limit, team: nil)
          team_id = team || @subreddit.team.id

          games = []
          end_date = Date.today + limit + 7

          # Go forward an extra week to account for off days
          team_schedule.games_between(Date.today, end_date, team: team_id)
            .each_value do |day|
              next if day[:date] < Date.today

              games.concat day[:games].reject(&:over?)

              break if games.count >= limit
            end

          games.first(limit)
        end

        def next_game_str(date_format: '%-m/%-d', team: nil)
          game = upcoming_games(1, team: team).first

          return '???' unless game

          if game.home_team?
            "#{game.date.strftime(date_format)} #{@subreddit.team.name} vs." \
            " #{game.opponent.name} #{game.date.strftime('%-I:%M %p')}"
          else
            "#{game.date.strftime(date_format)} #{@subreddit.team.name} @ " \
            "#{game.opponent.name} #{game.date.strftime('%-I:%M %p')}"
          end
        end

        def last_game_str(date_format: '%-m/%-d', team: nil)
          game = previous_games(1, team: team).first

          return '???' unless game

          "#{game.date.strftime(date_format)} #{@subreddit.team.name} " \
          "#{game.score[0]} #{game.opponent.name} #{game.score[1]}"
        end

        protected

        # This is the schedule generator for this subreddit, not necessarily
        # this subreddit's team.
        def team_schedule
          @team_schedule ||= SubredditScheduleGenerator.new(
            api: @bot.api,
            subreddit: @subreddit
          )
        end

        def cell(date, games, options = {})
          num = "^#{date}"

          return num if games.empty?

          # Let's hope nobody plays a doubleheader against two different teams
          subreddit = subreddit games.first.opponent.code

          # Spring training games sometimes are against colleges
          subreddit = subreddit&.downcase if options[:downcase]

          statuses = games.map(&:status)

          link = link_to '', sub: subreddit, title: statuses.join(', ')

          return bold "#{num} #{link}" if games[0].home_team?

          italic "#{num} #{link}"
        end
      end
    end
  end
end
