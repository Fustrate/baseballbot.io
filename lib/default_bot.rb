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
      user: ENV['PG_USERNAME'],
      dbname: ENV['PG_DATABASE'],
      password: ENV['PG_PASSWORD']
    },
    logger: Logger.new(arguments.key?(:log) ? STDOUT : '../log/baseballbot.log')
  )

  bot.use_account account if account

  bot
end

def arguments
  @arguments ||= begin
    parsed = ARGV
      .map { |arg| arg.split('=') }
      .map { |k, v| [k.downcase.to_sym, v || true] }

    Hash[parsed]
  end
end
