# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread < Base
      # This is kept here because of inheritance
      Dir.glob(
        File.join(File.dirname(__FILE__), 'game_thread', '*.rb')
      ).each { |file| require file }

      using TemplateRefinements

      include Template::GameThread::Batters
      include Template::GameThread::Game
      include Template::GameThread::Highlights
      include Template::GameThread::LineScore
      include Template::GameThread::Media
      include Template::GameThread::Pitchers
      include Template::GameThread::Postgame
      include Template::GameThread::ScoringPlays
      include Template::GameThread::Teams

      attr_reader :title, :post_id, :game_pk

      def initialize(body:, subreddit:, game_pk:, title: '', post_id: nil)
        super(body: body, subreddit: subreddit)

        @game_pk = game_pk
        @title = format_title title
        @post_id = post_id
      end

      def content
        @content ||= @bot.api.content @game_pk
      end

      def title=(new_title)
        @title = format_title new_title
      end

      def feed
        @feed ||= @bot.api.live_feed @game_pk
      end

      def linescore
        feed.linescore
      end

      def boxscore
        feed.boxscore
      end

      def game_data
        feed['gameData']
      end

      def schedule_data(hydrate: 'probablePitcher(note)')
        @bot.api.load("schedule_data_#{gid}_#{hydrate}", expires: 300) do
          @bot.api.schedule(gamePk: @game_pk, hydrate: hydrate)
        end
      end

      def inspect
        %(#<Baseballbot::Template::GameThread @game_pk="#{@game_pk}">)
      end

      def player_url(id)
        "http://mlb.mlb.com/team/player.jsp?player_id=#{id}"
      end

      def player_name(player)
        return 'TBA' unless player

        return player['boxscoreName'] if player['boxscoreName']

        if player['name'] && player['name']['boxscore']
          return player['name']['boxscore']
        end

        game_data.dig('players', "ID#{player['person']['id']}", 'boxscoreName')
      end

      def player_link(player, title: nil)
        url = player_url(player['id'] || player.dig('person', 'id'))
        link_to player_name(player), url: url, title: title
      end

      def gameday_link
        "https://www.mlb.com/gameday/#{game_pk}"
      end

      def game_graph_link
        'http://www.fangraphs.com/livewins.aspx?' \
        "date=#{date.strftime '%Y-%m-%d'}&team=#{team.name}&" \
        "dh=#{game_data.dig('game', 'gameNumber') - 1}&season=#{date.year}"
      end

      def strikezone_map_link
        'http://www.brooksbaseball.net/pfxVB/zoneTrack.php?' \
        "#{date.strftime 'month=%m&day=%d&year=%Y'}&game=gid_#{gid}%2F"
      end

      def game_notes_link(mlb_team)
        'http://www.mlb.com/mlb/presspass/gamenotes.jsp?' \
        "c_id=#{mlb_team.file_code}"
      end

      protected

      def format_title(title)
        title = start_time_local.strftime title

        # No interpolations? Great!
        return title unless title.match?(/%[{<]/)

        format title, title_interpolations
      end

      # rubocop:disable Metrics/MethodLength
      def title_interpolations
        {
          home_full_name: home_team.full_name,
          home_name: home_team.name,
          home_record: home_record,
          home_pitcher: player_name(probable_home_starter),
          home_runs: home_rhe['runs'],
          away_full_name: away_team.full_name,
          away_name: away_team.name,
          away_record: away_record,
          away_pitcher: player_name(probable_away_starter),
          away_runs: away_rhe['runs'],
          start_time: start_time_local.strftime('%-I:%M %p'),
          # /r/baseball always displays ET
          start_time_et: start_time_et.strftime('%-I:%M %p'),
          # Postseason
          series_game: '?', # @linescore.xpath('//game/@description').text,
          home_wins: '?',   # @linescore.xpath('//game/@home_wins').text,
          away_wins: '?'    # @linescore.xpath('//game/@away_wins').text
        }
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
