# frozen_string_literal: true
require_relative 'default_bot'

@remove_flairs = %w(eliminated-wagons)

@bot = default_bot(purpose: 'Chaos Flairs', account: 'BaseballBot')
@subreddit = @bot.session.subreddit('baseball')

def load_flairs(after: nil)
  puts "Loading flairs#{after ? " after #{after}" : ''}"

  flairs = @subreddit.flair_list(limit: 1000, after: after)

  flairs.each do |flair|
    next unless @remove_flairs.include?(flair[:flair_css_class])

    puts "\tChanging #{flair[:user]} from #{flair[:flair_css_class]} to CHAOS"

    @subreddit.set_flair(
      Redd::Models::User.new(nil, name: flair[:user]),
      'Team Chaos',
      css_class: 'CHAOS-wagon'
    )
  end

  return unless flairs.after

  sleep 5

  load_flairs after: flairs.after
end

load_flairs after: arguments[:after]
