# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat < Base
      # This is kept here because of inheritance
      Dir[File.join(File.dirname(__FILE__), 'gamechat', '*.rb')].each do |file|
        require file
      end

      using TemplateRefinements

      include Template::Gamechat::BoxScore
      include Template::Gamechat::Game
      include Template::Gamechat::Highlights
      include Template::Gamechat::LineScore
      include Template::Gamechat::Media
      include Template::Gamechat::Postgame
      include Template::Gamechat::ScoringPlays
      include Template::Gamechat::Teams

      attr_reader :title, :post_id

      def initialize(body:, bot:, subreddit:, game_pk:, title: '', post_id: nil)
        super(body: body, bot: bot)

        @subreddit = subreddit
        @game_pk = game_pk

        @title = format_title title
        @post_id = post_id
      end

      def game
        raise 'Gameday is no longer being used!'
      end

      def content
        @content ||= @bot.stats.content @game_pk
      end

      def feed
        @feed ||= @bot.stats.live_feed @game_pk
      end

      def linescore
        feed.linescore
      end

      def boxscore
        feed.boxscore
      end

      def inspect
        %(#<Baseballbot::Template::Gamechat @game_pk="#{@game_pk}">)
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

        feed.dig(
          'gameData', 'players', "ID#{player['person']['id']}", 'boxscoreName'
        )
      end

      def player_link(player, title: nil)
        link_to player_name(player), url: player_url(player['id']), title: title
      end

      def gameday_link
        "http://mlb.mlb.com/mlb/gameday/index.jsp?gid=#{gid}"
      end

      def game_graph_link
        'http://www.fangraphs.com/livewins.aspx?' \
        "date=#{date.strftime '%Y-%m-%d'}&team=#{team.name}&" \
        "dh=#{gid[-1].to_i - 1}&season=#{date.year}"
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
        title = @subreddit.timezone.strftime title

        # No interpolations? Great!
        return title unless title.match?(/%[{<]/)

        format title, title_interpolations
      end

      # rubocop:disable Metrics/MethodLength
      def title_interpolations
        {
          home_city: feed.dig('gameData', 'teams', 'home', 'locationName'),
          home_name: feed.dig('gameData', 'teams', 'home', 'teamName'),
          home_record: home_record,
          home_pitcher: player_name(probable_home_starter),
          home_runs: home_rhe['runs'],
          away_city: feed.dig('gameData', 'teams', 'away', 'locationName'),
          away_name: feed.dig('gameData', 'teams', 'away', 'teamName'),
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
