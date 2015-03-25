require 'redd'
require 'pg'
require 'chronic'
require 'mlb_gameday'
require 'erb'

Dir['baseballbot/**/*.rb'].each { |file| require_relative file }

class Baseballbot
  attr_reader :db, :gameday

  class << self
    def subreddits
      {
        'LAA' => 'AngelsBaseball',
        'HOU' => 'Astros',
        'OAK' => 'OaklandAthletics',
        'SEA' => 'Mariners',
        'TEX' => 'TexasRangers',
        'BAL' => 'Orioles',
        'BOS' => 'RedSox',
        'NYY' => 'NYYankees',
        'TB'  => 'TampaBayRays',
        'TOR' => 'TorontoBlueJays',
        'CWS' => 'WhiteSox',
        'CLE' => 'WahoosTipi',
        'DET' => 'MotorCityKitties',
        'KC'  => 'KCRoyals',
        'MIN' => 'MinnesotaTwins',
        'ARI' => 'azdiamondbacks',
        'COL' => 'ColoradoRockies',
        'LAD' => 'Dodgers',
        'SD'  => 'Padres',
        'SF'  => 'SFGiants',
        'ATL' => 'Braves',
        'MIA' => 'letsgofish',
        'NYM' => 'NewYorkMets',
        'PHI' => 'Phillies',
        'WSH' => 'Nationals',
        'CHC' => 'Cubs',
        'CIN' => 'Reds',
        'MIL' => 'Brewers',
        'PIT' => 'Buccos',
        'STL' => 'Cardinals'
      }.freeze
    end

    def subreddit_to_code(name)
      Hash[subreddits.invert.map { |k, v| [k.downcase, v] }][name]
    end
  end

  def initialize(options = {})
    @clients = Hash.new do |hash, key|
      hash[key] = Redd.it(
        :web,
        options[:reddit][:client_id],
        options[:reddit][:secret],
        options[:reddit][:redirect_uri],
        user_agent: options[:user_agent]
      )
    end

    @db = PG::Connection.new options[:db]

    @gameday = MLBGameday::API.new

    load_accounts
    load_subreddits
  end

  def inspect
    %(#<Baseballbot>)
  end

  def update_sidebars!(codes: [])
    teams_with_sidebars.each do |row|
      next unless codes.empty? || codes.include?(row['team_code'])

      update_sidebar! @subreddits[row['team_code']]
    end
  end

  def update_sidebar!(team)
    subreddit = team_to_subreddit(team)

    subreddit.update description: subreddit.generate_sidebar
  end

  def post_gamechats!(codes: [])
    unposted_gamechats.each do |row|
      next unless codes.empty? || codes.include?(row['team_code'])

      post_gamechat! id: row['id'],
                     team: row['team_code'],
                     gid: row['gid'],
                     title: row['title']
    end
  end

  def post_gamechat!(id:, team:, gid:, title:)
    post = team_to_subreddit(team).post_gamechat(gid: gid, title: title)

    @db.exec_params(
      'UPDATE gamechats
      SET post_id = $1, title = $2, status = $3
      WHERE id = $4',
      [
        post[:id],
        post[:title],
        'Posted',
        id
      ]
    )
  end

  def update_gamechats!(codes: [])
    active_gamechats.each do |row|
      next unless codes.empty? || codes.include?(row['team_code'])

      update_gamechat! id: row['id'],
                       team: row['team_code'],
                       gid: row['gid'],
                       post_id: row['post_id']
    end
  end

  def update_gamechat!(id:, team:, gid:, post_id:)
    over = team_to_subreddit(team).update_gamechat(gid: gid, post_id: post_id)

    return unless over

    @db.exec_params(
      "UPDATE gamechats
      SET status = 'Over'
      WHERE id = $1",
      [id]
    )
  end

  def in_subreddit(subreddit, &block)
    @clients[subreddit.account.name].with(subreddit.account.access) do |client|
      client.refresh_access! if subreddit.account.access.expired?

      block.call client
    end
  end

  protected

  def unposted_gamechats
    @db.exec_params(
      "SELECT gamechats.id, gid, team_code, title
      FROM gamechats
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status = 'Future' AND post_at <= $1",
      [Time.now.strftime('%Y-%m-%d %H:%M:%S')]
    )
  end

  def active_gamechats
    @db.exec_params(
      "SELECT gamechats.id, gid, team_code, post_id
      FROM gamechats
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status = 'Posted' AND starts_at <= $1",
      [Time.now.strftime('%Y-%m-%d %H:%M:%S')]
    )
  end

  def teams_with_sidebars
    @db.exec(
      "SELECT team_code
      FROM subreddits
      JOIN templates ON (subreddit_id = subreddits.id AND type = 'sidebar')"
    )
  end

  def team_to_subreddit(team)
    team.is_a?(Subreddit) ? team : @subreddits[team]
  end

  def load_accounts
    @accounts = {}

    @db.exec('SELECT * FROM accounts').each do |row|
      @accounts[row['id']] = Account.new(
        bot: self,
        name: row['name'],
        access: {
          access_token: row['access_token'],
          refresh_token: row['refresh_token'],
          scope: row['scope'][1..-2].split(','),
          expires_at: Chronic.parse(row['expires_at'])
        }
      )
    end
  end

  def load_subreddits
    @subreddits = {}

    @db.exec(
      'SELECT subreddits.*
      FROM subreddits
      LEFT JOIN accounts ON (account_id = accounts.id)'
    ).each do |row|
      @subreddits[row['team_code']] = Subreddit.new(
        bot: self,
        id: row['id'].to_i,
        name: row['name'],
        account: @accounts[row['account_id']]
      )
    end
  end
end
