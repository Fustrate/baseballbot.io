# frozen_string_literal: true

require_relative 'default_bot'

@changes = { 'old classes' => 'new classes' }

@bot = default_bot(purpose: 'Merge Flairs', account: 'BaseballBot')
@subreddit = @bot.session.subreddit('baseball')

def load_flairs(after: nil)
  puts "Loading flairs#{after ? " after #{after}" : ''}"

  flairs = @subreddit.flair_listing(limit: 1000, after: after)

  flairs.each do |flair|
    next unless @changes[flair[:flair_css_class]]

    puts "\tChanging #{flair[:user]} from #{flair[:flair_css_class]} " \
         "to #{@changes[flair[:flair_css_class]]}"

    @subreddit.set_flair(
      Redd::Models::User.new(nil, name: flair[:user]),
      flair[:flair_text],
      css_class: @changes[flair[:flair_css_class]]
    )
  end

  return unless flairs.after

  sleep 5

  load_flairs after: flairs.after
end

load_flairs after: arguments[:after]
