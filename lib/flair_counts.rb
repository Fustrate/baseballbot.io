# frozen_string_literal: true

require_relative 'default_bot'

@name = ARGV[0]

raise 'Please enter a subreddit name' unless @name

@bot = DefaultBot.create(purpose: 'Flair Stats')
@subreddit = @bot.session.subreddit(@name)
@bot.use_account @bot.name_to_subreddit(@name).account.name

@counts = Hash.new { |h, k| h[k] = 0 }

def load_flairs(after: nil)
  puts "Loading flairs#{after ? " after #{after}" : ''}"

  res = @subreddit.client
    .get("/r/#{@name}/api/flairlist", after: after, limit: 1000)
    .body

  res[:users].each { |flair| @counts[flair[:flair_css_class]] += 1 }

  if res[:next]
    sleep 5

    return load_flairs after: res[:next]
  end

  @counts.each { |name, count| puts "\"#{name}\",#{count}" }
end

# We can't restart this, so start from the beginning
load_flairs
