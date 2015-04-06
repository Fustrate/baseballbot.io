require 'redd'
require 'pg'
require 'chronic'
require 'mlb_gameday'
require 'erb'
require 'tzinfo'

Dir['baseballbot/**/*.rb'].each { |file| require_relative file }

class Baseballbot
  attr_reader :db, :gameday, :clients

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

  def update_sidebars!(names: [])
    teams_with_sidebars.each do |row|
      next unless names.empty? || names.include?(row['name'])

      update_sidebar! @subreddits[row['name']]
    end
  end

  def update_sidebar!(team)
    subreddit = team_to_subreddit(team)

    subreddit.update description: subreddit.generate_sidebar
  end

  def post_gamechats!(names: [])
    unposted_gamechats.each do |row|
      next unless names.empty? || names.include?(row['name'])

      post_gamechat! id: row['id'],
                     subreddit: row['name'],
                     gid: row['gid']
    end
  end

  def post_gamechat!(id:, subreddit:, gid:)
    post = @subreddits[subreddit].post_gamechat(gid: gid)

    post.edit CGI.unescapeHTML(post[:selftext]).gsub('#ID#', post[:id])

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

  def update_gamechats!(names: [])
    active_gamechats.each do |row|
      next unless names.empty? || names.include?(row['name'])

      update_gamechat! id: row['id'],
                       subreddit: row['name'],
                       gid: row['gid'],
                       post_id: row['post_id']
    end
  end

  def update_gamechat!(id:, subreddit:, gid:, post_id:)
    over = @subreddits[subreddit].update_gamechat(gid: gid, post_id: post_id)

    return unless over

    @db.exec_params(
      "UPDATE gamechats
      SET status = 'Over'
      WHERE id = $1",
      [id]
    )
  rescue StandardError
    puts "Could not update #{post_id} for team #{team}."
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
      "SELECT gamechats.id, gid, subreddits.name
      FROM gamechats
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status = 'Future' AND post_at <= $1
        AND (options#>>'{gamechats,enabled}')::boolean IS TRUE
      ORDER BY post_at ASC, gid ASC",
      [Time.now.strftime('%Y-%m-%d %H:%M:%S')]
    )
  end

  def active_gamechats
    @db.exec_params(
      "SELECT gamechats.id, gid, subreddits.name, post_id
      FROM gamechats
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status = 'Posted' AND starts_at <= $1
        AND (options#>>'{gamechats,enabled}')::boolean IS TRUE
      ORDER BY post_id ASC",
      [Time.now.strftime('%Y-%m-%d %H:%M:%S')]
    )
  end

  def teams_with_sidebars
    @db.exec(
      "SELECT name
      FROM subreddits
      WHERE (options#>>'{sidebar,enabled}')::boolean IS TRUE
      ORDER BY id ASC"
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
      @subreddits[row['name']] = Subreddit.new(
        bot: self,
        id: row['id'].to_i,
        name: row['name'],
        code: row['team_code'],
        account: @accounts[row['account_id']],
        options: JSON.load(row['options'])
      )
    end
  end
end
