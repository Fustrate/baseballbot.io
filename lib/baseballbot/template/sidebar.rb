# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar < Base
      Dir.glob(
        File.join(File.dirname(__FILE__), '{sidebar,shared}/*.rb')
      ).each { |file| require file }

      include Template::Sidebar::Calendar
      include Template::Sidebar::Leaders
      include Template::Sidebar::TodaysGames

      include Template::Shared::Standings

      def inspect
        %(#<Baseballbot::Template::Sidebar @subreddit="#{@subreddit.name}">)
      end

      def updated_with_link
        timestamp = @subreddit.now.strftime '%-m/%-d at %-I:%M %p %Z'

        "[Updated](/r/baseballbot) #{timestamp}"
      end

      protected

      def wildcard(wcgb)
        wcgb.to_f * (wcgb[0] == '+' ? -1 : 1)
      end

      def open_url(url, interpolations = {})
        interpolations[:team_id] = @subreddit.team.id

        URI.parse(format(url, interpolations)).open.read
      end
    end
  end
end
