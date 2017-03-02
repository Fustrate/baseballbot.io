# frozen_string_literal: true
require_relative 'baseballbot'

module Redd
  module Objects
    class Subreddit < Thing
      def delete_flair(username)
        post("/r/#{display_name}/api/deleteflair", name: username)
      end
    end
  end
end

@bot = Baseballbot.new(
  reddit: {
    user_agent: 'Baseballbot by /u/Fustrate',
    client_id: ENV['REDDIT_CLIENT_ID'],
    secret: ENV['REDDIT_SECRET'],
    redirect_uri: ENV['REDDIT_REDIRECT_URI']
  },
  db: {
    user: ENV['PG_USERNAME'],
    dbname: ENV['PG_DATABASE'],
    password: ENV['PG_PASSWORD']
  },
  user_agent: 'BaseballBot by /u/Fustrate - Flairs'
)

@client = @bot.clients['BaseballBot']
@access = @bot.accounts
              .select { |_, a| a.name == 'BaseballBot' }
              .values
              .first
              .access
@delete = %w(MIN-wagon).freeze

def load_flairs(after: nil)
  puts "Loading flairs#{after ? " after #{after}" : ''}"

  flairs = @subreddit.get_flairlist(limit: 1000, after: after)

  flairs.each do |flair|
    next unless @delete.include?(flair.flair_css_class)

    puts "\tDeleting #{flair.user}'s flair " \
         "('#{flair.flair_css_class}', '#{flair.flair_text}')"

    @subreddit.delete_flair(flair.user)
  end

  return unless flairs.after

  sleep 3
  # puts "AFTER: #{flairs.after}"
  load_flairs after: flairs.after
end

@client.with(@access) do
  @subreddit = @client.subreddit_from_name('baseball')

  load_flairs
end
