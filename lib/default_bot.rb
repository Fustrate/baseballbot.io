# frozen_string_literal: true

# The bare basics of most files in /lib/
require_relative 'baseballbot'

def default_bot(purpose: nil, account: nil)
  bot = Baseballbot.new(
    reddit: {
      user_agent: ['Baseballbot by /u/Fustrate', purpose].compact.join(' - '),
      client_id: ENV['REDDIT_CLIENT_ID'],
      secret: ENV['REDDIT_SECRET'],
      redirect_uri: ENV['REDDIT_REDIRECT_URI']
    },
    db: {
      user: ENV['BASEBALLBOT_PG_USERNAME'],
      dbname: ENV['BASEBALLBOT_PG_DATABASE'],
      password: ENV['BASEBALLBOT_PG_PASSWORD']
    },
    logger: Logger.new(log_location)
  )

  bot.use_account account if account

  bot
end

def arguments
  @arguments ||= ARGV
    .map { |arg| arg.split('=') }
    .map { |k, v| [k.downcase.to_sym, v || true] }
    .to_h
end

def log_location
  return STDOUT if arguments.key?(:log)

  File.expand_path('../log/baseballbot.log', __dir__)
end
