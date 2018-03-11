# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar < Base
      Dir[File.join(File.dirname(__FILE__), 'sidebar', '*.rb')].each do |file|
        require file
      end

      include Template::Sidebar::Calendar
      include Template::Sidebar::Leaders
      include Template::Sidebar::Standings
      include Template::Sidebar::TodaysGames

      def initialize(body:, bot:, subreddit:)
        super(body: body, bot: bot)

        @subreddit = subreddit
        @team = subreddit.team
      end

      def inspect
        %(#<Baseballbot::Template::Sidebar @team="#{@team.name}">)
      end

      def updated_with_link
        timestamp = @subreddit.timezone.strftime '%-m/%-d at %-I:%M %p %Z'

        "[Updated](/r/baseballbot) #{timestamp}"
      end

      protected

      def wildcard(wcgb)
        wcgb.to_f * (wcgb[0] == '+' ? -1 : 1)
      end

      def open_url(url, interpolations = {})
        interpolations[:team_id] = @team.id
        interpolations[:team_code] = @team.file_code

        open(format(url, interpolations)).read
      end
    end
  end
end
