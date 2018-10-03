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
require_relative 'baseballbot/game_threads'
require_relative 'baseballbot/off_day'
require_relative 'baseballbot/pregames'
require_relative 'baseballbot/sidebars'
require_relative 'baseballbot/subreddits'

Dir.glob(
  File.join(File.dirname(__FILE__), 'baseballbot/{template,posts}/*.rb')
).sort.each { |file| require_relative file }

IGNORED_EXCEPTIONS = [::Redd::ServerError, ::OpenURI::HTTPError].freeze

Honeybadger.configure do |config|
  config.before_notify do |notice|
    if IGNORED_EXCEPTIONS.any? { |klass| notice.exception.is_a?(klass) }
      notice.halt!
    end
  end
end

class Baseballbot
  include Accounts
  include GameThreads
  include OffDay
  include Pregames
  include Sidebars
  include Subreddits

  attr_reader :db, :api, :client, :session, :redis, :logger

  def initialize(options = {})
    @client = Redd::APIClient.new(
      redd_auth_strategy(options[:reddit]),
      limit_time: 0
    )
    @session = Redd::Models::Session.new(@client)

    @db = PG::Connection.new options[:db]
    @redis = Redis.new

    @logger = options[:logger] || Logger.new(STDOUT)

    @api = MLBStatsAPI::Client.new(logger: @logger, cache: @redis)
  end

  def redd_auth_strategy(config)
    Redd::AuthStrategies::Web.new(
      client_id: config[:client_id],
      secret: config[:secret],
      redirect_uri: config[:redirect_uri],
      user_agent: config[:user_agent]
    )
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

  def self.adjust_time_proc(post_at)
    if post_at =~ /\A\-?\d{1,2}\z/
      ->(time) { time - Regexp.last_match[0].to_i.abs * 3600 }
    elsif post_at =~ /(1[012]|\d)(:\d\d|) ?(am|pm)/i
      constant_time(Regexp.last_match)
    else
      # Default to 3 hours before game time
      ->(time) { time - 3 * 3600 }
    end
  end

  def self.constant_time(match_data)
    lambda do |time|
      hours = match_data[1].to_i
      hours += 12 if hours != 12 && match_data[3].casecmp('pm').zero?
      minutes = (match_data[2] || ':00')[1..2].to_i

      Time.new(time.year, time.month, time.day, hours, minutes, 0)
    end
  end
end
