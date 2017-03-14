# frozen_string_literal: true
require_relative 'default_bot'

@after = nil

@bot = default_bot(purpose: 'Flair Stats', account: 'BaseballBot')
@subreddit = @bot.session.subreddit('baseball')

@counts = Hash.new { |h, k| h[k] = 0 }

def load_flairs(after: nil)
  puts "Loading flairs#{after ? " after #{after}" : ''}"

  flairs = @subreddit.flair_listing(limit: 1000, after: after)

  flairs.each { |flair| @counts[flair[:flair_css_class]] += 1 }

  if flairs.after
    sleep 5

    return load_flairs after: flairs.after
  end

  puts @counts.inspect
end

load_flairs after: @after
