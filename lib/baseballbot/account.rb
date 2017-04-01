# frozen_string_literal: true

class Baseballbot
  class Account
    attr_reader :access, :name

    def initialize(bot:, name:, access:)
      @bot = bot
      @name = name
      @access = access
    end
  end
end
