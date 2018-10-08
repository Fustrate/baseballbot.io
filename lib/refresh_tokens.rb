# frozen_string_literal: true

require_relative 'default_bot'

@bot = DefaultBot.create(purpose: 'Refresh Tokens')

@bot.accounts.each_value do |account|
  unless account.access.expired?
    puts "Skipping #{account.name}"

    next
  end

  begin
    puts "Refreshing #{account.name}"

    @bot.use_account account.name
  rescue Redd::APIError => e
    puts "\tError: #{e.class}"
  end

  sleep 5
end
