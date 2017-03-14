# frozen_string_literal: true
require_relative 'default_bot'

@bot = default_bot(purpose: 'Refresh Tokens')

@bot.accounts.each do |_, account|
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
