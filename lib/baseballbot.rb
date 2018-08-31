# frozen_string_literal: true

require 'chronic'
require 'erb'
require 'honeybadger/ruby'
require 'logger'
require 'mlb_stats_api'
require 'open-uri'
require 'pg'
require 'redd'
require 'redis'
require 'tzinfo'

require_relative 'baseballbot/error'
require_relative 'baseballbot/subreddit'
require_relative 'baseballbot/account'

require_relative 'baseballbot/accounts'
require_relative 'baseballbot/gamechats'
require_relative 'baseballbot/off_day'
require_relative 'baseballbot/pregames'
require_relative 'baseballbot/sidebars'
require_relative 'baseballbot/subreddits'

Dir.glob(
  File.join(File.dirname(__FILE__), 'baseballbot/{template,posts}/*.rb')
).each { |file| require_relative file }

class Baseballbot
  include Accounts
  include Gamechats
  include OffDay
  include Pregames
  include Sidebars
  include Subreddits

  attr_reader :db, :api, :client, :session, :redis, :logger

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

    @logger = options[:logger] || Logger.new(STDOUT)

    @api = MLBStatsAPI::Client.new(logger: @logger, cache: @redis)
  end

  def inspect
    %(#<Baseballbot>)
  end

  def accounts
    @accounts ||= load_accounts
  end

  def subreddits
    @subreddits ||= load_subreddits
  end

  def self.parse_time(utc, in_time_zone:)
    utc = Time.parse(utc).utc unless utc.is_a? Time
    period = in_time_zone.period_for_utc(utc)
    with_offset = utc + period.utc_total_offset

    Time.parse "#{with_offset.strftime('%FT%T')} #{period.zone_identifier}"
  end
end
