# frozen_string_literal: true

# The bare basics of most files in /lib/
require_relative 'baseballbot'

module DefaultBot
  def self.create(purpose: nil, account: nil)
    bot = Baseballbot.new(
      user_agent: ['Baseballbot by /u/Fustrate', purpose].compact.join(' - '),
      logger: Logger.new(log_location)
    )

    bot.use_account account if account

    bot
  end

  def self.log_location
    return STDOUT if ARGV.any? { |arg| arg.match?(/\Alog=(?:1|stdout)\z/i) }

    File.expand_path '../log/baseballbot.log', __dir__
  end
end
