# frozen_string_literal: true
require 'redd'
require 'pg'
require 'chronic'
require 'mlb_gameday'
require 'erb'
require 'tzinfo'
require 'redis'

require_relative 'baseballbot/error'
require_relative 'baseballbot/subreddit'
require_relative 'baseballbot/account'
require_relative 'baseballbot/template/base'
require_relative 'baseballbot/template/gamechat'
require_relative 'baseballbot/template/sidebar'

class Baseballbot
  attr_reader :db, :gameday, :client, :session, :accounts, :redis,
              :current_account, :logger

  class << self
    # The default subreddits for each team, as used by /r/baseball. These can
    # be overridden on a team-by-team basis in their templates.
    # rubocop:disable Metrics/MethodLength
    def subreddits
      {
        'ARI' => 'azdiamondbacks',
        'ATL' => 'Braves',
        'BAL' => 'Orioles',
        'BOS' => 'RedSox',
        'CHC' => 'CHICubs',
        'CIN' => 'Reds',
        'CLE' => 'WahoosTipi',
        'COL' => 'ColoradoRockies',
        'CWS' => 'WhiteSox',
        'DET' => 'MotorCityKitties',
        'HOU' => 'Astros',
        'KC'  => 'KCRoyals',
        'LAA' => 'AngelsBaseball',
        'LAD' => 'Dodgers',
        'MIA' => 'letsgofish',
        'MIL' => 'Brewers',
        'MIN' => 'MinnesotaTwins',
        'NYM' => 'NewYorkMets',
        'NYY' => 'NYYankees',
        'OAK' => 'OaklandAthletics',
        'PHI' => 'Phillies',
        'PIT' => 'Buccos',
        'SD'  => 'Padres',
        'SEA' => 'Mariners',
        'SF'  => 'SFGiants',
        'STL' => 'Cardinals',
        'TB'  => 'TampaBayRays',
        'TEX' => 'TexasRangers',
        'TOR' => 'TorontoBlueJays',
        'WSH' => 'Nationals'
      }.freeze
    end
    # rubocop:enable Metrics/MethodLength

    def subreddit_to_code(name)
      Hash[subreddits.invert.map { |k, v| [k.downcase, v] }][name.downcase]
    end
  end

  def initialize(options = {})
    @client = Redd::APIClient.new(
      Redd::AuthStrategies::Web.new(
        client_id: options[:reddit][:client_id],
        secret: options[:reddit][:secret],
        redirect_uri: options[:reddit][:redirect_uri],
        user_agent: options[:reddit][:user_agent]
      ),
      limit_time: 0
    )
    @session = Redd::Models::Session.new(@client)

    @db = PG::Connection.new options[:db]
    @redis = Redis.new
    @gameday = MLBGameday::API.new

    @logger = options[:logger] || Logger.new(STDOUT)

    load_accounts
    load_subreddits
  end

  def inspect
    %(#<Baseballbot>)
  end

  def use_account(name)
    unless @current_account&.name == name
      @current_account = @accounts.values.find { |acct| acct.name == name }

      @client.access = @current_account.access
    end

    refresh_access! if @current_account.access.expired?
  end

  def update_sidebars!(names: [])
    names = names.map(&:downcase)

    teams_with_sidebars.each do |row|
      next unless names.empty? || names.include?(row['name'].downcase)

      update_sidebar! @subreddits[row['name']]
    end
  end

  def update_sidebar!(team)
    subreddit = team_to_subreddit(team)

    subreddit.update description: subreddit.generate_sidebar
  rescue Redd::InvalidAccess
    puts "Could not update #{subreddit.name} due to invalid credentials:"
    puts "\tExpires: #{current_account.access.expires_at.strftime '%F %T'}"
    puts "\tCurrent: #{Time.now.strftime '%F %T'}"

    refresh_access!

    puts "\tExpires: #{current_account.access.expires_at.strftime '%F %T'}"

    subreddit.update description: subreddit.generate_sidebar
  rescue Redd::APIError, ::OpenURI::HTTPError
    # do nothing, it's not the end of the world
    nil
  end

  def post_pregames!(names: [])
    names = names.map(&:downcase)

    unposted_pregames.each do |row|
      next unless names.empty? || names.include?(row['name'].downcase)

      post_pregame! id: row['id'], team: row['name'], gid: row['gid']
    end
  end

  def post_pregame!(id:, team:, gid:)
    team_to_subreddit(team).post_pregame(id: id, gid: gid)
  end

  def post_gamechats!(names: [])
    names = names.map(&:downcase)

    unposted_gamechats.each do |row|
      next unless names.empty? || names.include?(row['name'].downcase)

      post_gamechat! id: row['id'],
                     team: row['name'],
                     gid: row['gid'],
                     title: row['title']
    end
  end

  def post_gamechat!(id:, team:, gid:, title:)
    team_to_subreddit(team).post_gamechat(
      id: id,
      gid: gid,
      title: title
    )
  end

  def update_gamechats!(names: [])
    names = names.map(&:downcase)

    active_gamechats.each do |row|
      next unless names.empty? || names.include?(row['name'].downcase)

      update_gamechat! id: row['id'],
                       team: row['name'],
                       gid: row['gid'],
                       post_id: row['post_id']
    end
  end

  def update_gamechat!(id:, team:, gid:, post_id:, first_attempt: true)
    team_to_subreddit(team)
      .update_gamechat(id: id, gid: gid, post_id: post_id)
  rescue Redd::InvalidAccess
    return false unless first_attempt

    puts "Could not update #{subreddit.name} due to invalid credentials:"
    puts "\tExpires: #{current_account.access.expires_at.strftime '%F %T'}"
    puts "\tCurrent: #{Time.now.strftime '%F %T'}"

    refresh_access!

    puts "\tExpires: #{current_account.access.expires_at.strftime '%F %T'}"

    update_gamechat!(
      id: id,
      team: team,
      gid: gid,
      post_id: post_id,
      first_attempt: false
    )
  rescue Redd::APIError, ::OpenURI::HTTPError
    # All the same type of error. Waiting an extra 2 minutes won't kill anyone.
    nil
  rescue StandardError => e
    puts "[#{Time.now.strftime '%Y-%m-%d %H:%M:%S'}] #{e.class}: " \
         "Could not update #{post_id} for team #{team}."
    puts "\t#{e.message}"
    puts "\t#{e.backtrace}"
  end

  def refresh_access!
    @client.refresh

    new_expiration = Time.now + @client.access.expires_in

    @db.exec_params(
      'UPDATE accounts
      SET access_token = $1, expires_at = $2
      WHERE refresh_token = $3',
      [
        @client.access.access_token,
        new_expiration.strftime('%Y-%m-%d %H:%M:%S'),
        @client.access.refresh_token
      ]
    )

    client
  end

  def team_to_subreddit(team)
    team.is_a?(Subreddit) ? team : @subreddits[team.downcase]
  end

  protected

  def load_accounts
    @accounts = {}

    @db.exec('SELECT * FROM accounts').each { |row| add_account row }
  end

  def add_account(row)
    expires_at = Chronic.parse row['expires_at']

    @accounts[row['id']] = Account.new(
      bot: self,
      name: row['name'],
      access: Redd::Models::Access.new(
        @client,
        access_token: row['access_token'],
        refresh_token: row['refresh_token'],
        scope: row['scope'][1..-2].split(','),
        # Remove 60 seconds so we don't run into invalid credentials
        expires_at: expires_at - 60,
        expires_in: expires_at - Time.now
      )
    )
  end

  def load_subreddits
    @subreddits = {}

    @db.exec(
      'SELECT subreddits.*
      FROM subreddits
      LEFT JOIN accounts ON (account_id = accounts.id)'
    ).each { |row| add_subreddit row }
  end

  def add_subreddit(row)
    @subreddits[row['name'].downcase] = Subreddit.new(
      bot: self,
      id: row['id'].to_i,
      name: row['name'],
      code: row['team_code'],
      account: @accounts[row['account_id']],
      options: JSON.parse(row['options'])
    )
  end

  # !@group SQL

  def unposted_pregames
    @db.exec(
      "SELECT gamechats.id, gid, subreddits.name
      FROM gamechats
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status = 'Future'
        AND (options#>>'{pregame,enabled}')::boolean IS TRUE
        AND (
          CASE WHEN substr(options#>>'{pregame,post_at}', 1, 1) = '-'
            THEN (starts_at::timestamp + (
              CONCAT(options#>>'{pregame,post_at}', ' hours')
            )::interval) < NOW()
            ELSE (
              DATE(starts_at) + (options#>>'{pregame,post_at}')::interval
            ) < NOW() AT TIME ZONE (options->>'timezone')
          END)
      ORDER BY post_at ASC, gid ASC"
    )
  end

  def unposted_gamechats
    @db.exec(
      "SELECT gamechats.id, gid, subreddits.name, title
      FROM gamechats
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status IN ('Pregame', 'Future')
        AND post_at <= NOW()
        AND (options#>>'{gamechats,enabled}')::boolean IS TRUE
      ORDER BY post_at ASC, gid ASC"
    )
  end

  def active_gamechats
    @db.exec(
      "SELECT gamechats.id, gid, subreddits.name, post_id
      FROM gamechats
      JOIN subreddits ON (subreddits.id = subreddit_id)
      WHERE status = 'Posted'
        AND starts_at <= NOW()
        AND (options#>>'{gamechats,enabled}')::boolean IS TRUE
      ORDER BY post_id ASC"
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

  # !@endgroup
end
