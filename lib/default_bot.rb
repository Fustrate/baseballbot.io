# frozen_string_literal: true

# The bare basics of most files in /lib/
require_relative 'baseballbot'

module DefaultBot
  def self.create(purpose: nil, account: nil)
    bot = Baseballbot.new(
      reddit: reddit_settings(purpose),
      logger: Logger.new(log_location)
    )

    bot.use_account account if account

    bot
  end

  def self.reddit_settings(purpose)
    {
      user_agent: ['Baseballbot by /u/Fustrate', purpose].compact.join(' - '),
      client_id: ENV['REDDIT_CLIENT_ID'],
      secret: ENV['REDDIT_SECRET'],
      redirect_uri: ENV['REDDIT_REDIRECT_URI']
    }
  end

  def self.log_location
    return STDOUT if ARGV.any? { |arg| arg.match?(/\Alog=(?:1|stdout)\z/i) }

    File.expand_path('../log/baseballbot.log', __dir__)
  end
end
