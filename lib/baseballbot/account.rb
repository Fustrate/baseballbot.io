class Baseballbot
  class Account
    attr_reader :access

    def initialize(bot:, name:, access:)
      @bot = bot
      @name = name

      @access = Redd::Access.new(
        access_token: access[:access_token],
        refresh_token: access[:refresh_token],
        scope: access[:scope].join(','),
        expires_at: access[:expires_at].to_i
      )
    end
  end
end
