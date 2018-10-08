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
require_relative 'baseballbot/utility'

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

  def initialize(options = {})
    @options = options
  end

  def api
    @api ||= MLBStatsAPI::Client.new logger: logger, cache: redis
  end

  def client
    unless @options[:reddit]
      raise 'BaseballBot was not initialized with a reddit configuration.'
    end

    return @client if @client

    @client = Redd::APIClient.new redd_auth_strategy, limit_time: 0
  end

  def db
    @db ||= PG::Connection.new(
      user: ENV['BASEBALLBOT_PG_USERNAME'],
      dbname: ENV['BASEBALLBOT_PG_DATABASE'],
      password: ENV['BASEBALLBOT_PG_PASSWORD']
    )
  end

  def logger
    @logger ||= @options[:logger] || Logger.new(STDOUT)
  end

  def redis
    @redis ||= Redis.new
  end

  def session
    unless @options[:reddit]
      raise 'BaseballBot was not initialized with a reddit configuration.'
    end

    @session ||= Redd::Models::Session.new client
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

  protected

  def redd_auth_strategy
    Redd::AuthStrategies::Web.new(
      client_id: ENV['REDDIT_CLIENT_ID'],
      secret: ENV['REDDIT_SECRET'],
      redirect_uri: ENV['REDDIT_REDIRECT_URI'],
      user_agent: @options[:user_agent]
    )
  end
end
