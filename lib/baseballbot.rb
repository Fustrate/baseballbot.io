# frozen_string_literal: true

require 'redd'
require 'pg'
require 'chronic'
require 'mlb_gameday'
require 'mlb_stats_api'
require 'erb'
require 'tzinfo'
require 'redis'
require 'logger'
require 'honeybadger/ruby'

require_relative 'baseballbot/error'
require_relative 'baseballbot/subreddit'
require_relative 'baseballbot/account'

require_relative 'baseballbot/accounts'
require_relative 'baseballbot/gamechats'
require_relative 'baseballbot/pregames'
require_relative 'baseballbot/sidebars'
require_relative 'baseballbot/subreddits'

require_relative 'baseballbot/template/base'
require_relative 'baseballbot/template/gamechat'
require_relative 'baseballbot/template/sidebar'

class Baseballbot
  include Accounts
  include Gamechats
  include Pregames
  include Sidebars
  include Subreddits

  attr_reader :db, :gameday, :stats, :client, :session, :redis, :logger

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
    @stats = MLBStatsAPI::Client.new

    @logger = options[:logger] || Logger.new(STDOUT)

    @accounts = load_accounts
    @subreddits = load_subreddits
  end

  def inspect
    %(#<Baseballbot>)
  end
end
