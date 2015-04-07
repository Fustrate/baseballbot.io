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

      attr_reader :time

      def initialize(body:, bot:, subreddit:)
        super(body: body, bot: bot)

        @subreddit = subreddit
        @team = subreddit.team
        @time = subreddit.time
      end

      def inspect
        %(#<Baseballbot::Template::Sidebar @team="#{@team.name}">)
      end

      def updated_with_link
        "[Updated](/r/baseballbot) #{time.strftime '%-m/%-d at %-I:%M %p %Z'}"
      end

      protected

      def wildcard(wcgb)
        wcgb.to_f * (wcgb[0] == '+' ? -1 : 1)
      end

      def open_url(url, interpolations = {})
        interpolations.merge! team_id: @team.id,
                              team_code: @team.file_code

        open format(url, interpolations)
      end
    end
  end
end
