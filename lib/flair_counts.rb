# frozen_string_literal: true

require_relative 'default_bot'

@bot = default_bot(purpose: 'Flair Stats', account: 'BaseballBot')
@subreddit = @bot.session.subreddit('baseball')

@counts = Hash.new { |h, k| h[k] = 0 }

def load_flairs(after: nil)
  puts "Loading flairs#{after ? " after #{after}" : ''}"

  res = @subreddit.client.get('/r/baseball/api/flairlist', params).body

  res[:users].each { |flair| @counts[flair[:flair_css_class]] += 1 }

  if res[:next]
    sleep 5

    return load_flairs after: res[:next]
  end

  @counts.each { |name, count| puts "\"#{name}\",#{count}" }
end

load_flairs after: arguments[:after]
