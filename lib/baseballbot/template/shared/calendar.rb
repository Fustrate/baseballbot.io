# frozen_string_literal: true

require_relative '../markdown_calendar'
require_relative '../team_calendar'

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

          @previous ||= {}
          @previous[team_id] ||= []

          if @previous[team_id].count >= limit
            return @previous[team_id].first(limit)
          end

          # Go backwards an extra week to account for off days
          team_schedule
            .games_between(Date.today - limit - 7, Date.today, team: team_id)
            .values
            .reverse_each do |day|
              next if day[:date] > Date.today

              day[:games].each do |game|
                @previous[team_id] << game if game[:over]
              end

              break if @previous[team_id].count >= limit
            end

          @previous[team_id].first(limit)
        end

        def upcoming_games(limit, team: nil)
          team_id = team || @subreddit.team.id

          @upcoming ||= {}
          @upcoming[team_id] ||= []

          if @upcoming[team_id].count >= limit
            return @upcoming[team_id].first(limit)
          end

          # Go forward an extra week to account for off days
          team_schedule
            .games_between(Date.today, Date.today + limit + 7, team: team_id)
            .each_value do |day|
              next if day[:date] < Date.today

              day[:games].each do |game|
                @upcoming[team_id] << game unless game[:over]
              end

              break if @upcoming[team_id].count >= limit
            end

          @upcoming[team_id].first(limit)
        end

        def next_game_str(date_format: '%-m/%-d', team: nil)
          game = upcoming_games(1, team: team).first

          return '???' unless game

          if game[:home]
            "#{game[:date].strftime(date_format)} #{@subreddit.team.name} vs." \
            " #{game[:opponent].name} #{game[:date].strftime('%-I:%M %p')}"
          else
            "#{game[:date].strftime(date_format)} #{@subreddit.team.name} @ " \
            "#{game[:opponent].name} #{game[:date].strftime('%-I:%M %p')}"
          end
        end

        def last_game_str(date_format: '%-m/%-d', team: nil)
          game = previous_games(1, team: team).first

          return '???' unless game

          "#{game[:date].strftime(date_format)} #{@subreddit.team.name} " \
          "#{game[:score][0]} #{game[:opponent].name} #{game[:score][1]}"
        end

        protected

        def team_schedule
          @team_schedule ||= TeamSchedule.new(bot: @bot, subreddit: @subreddit)
        end

        def cell(date, games, options = {})
          num = "^#{date}"

          return num if games.empty?

          # Let's hope nobody plays a doubleheader against two different teams
          subreddit = subreddit games.first[:opponent].code

          # Spring training games sometimes are against colleges
          subreddit = subreddit.downcase if subreddit && options[:downcase]

          statuses = games.map { |game| game[:status] }

          link = link_to '', sub: subreddit, title: statuses.join(', ')

          games[0][:home] ? (bold "#{num} #{link}") : (italic "#{num} #{link}")
        end
      end
    end
  end
end
