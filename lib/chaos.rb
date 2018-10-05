# frozen_string_literal: true

require_relative 'default_bot'

@remove_flairs = ARGV[0]&.split(',')

raise 'Please pass a flair class as an argument.' unless @remove_flairs&.any?

puts "Removing #{@remove_flairs.join(', ')}"

@bot = default_bot(purpose: 'Chaos Flairs', account: 'BaseballBot')
@subreddit = @bot.session.subreddit('baseball')

@removed = Hash.new { |h, k| h[k] = 0 }

def load_flairs(after: nil)
  puts "Loading flairs#{after ? " after #{after}" : ''}"

  res = @subreddit.client
    .get('/r/baseball/api/flairlist', after: after, limit: 1000)
    .body

  res[:users].each { |flair| update_flair(flair) }

  return unless res[:next]

  sleep 5

  load_flairs after: res[:next]
end

def update_flair(flair)
  return unless @remove_flairs.include?(flair[:flair_css_class])

  puts "\tChanging #{flair[:user]} from #{flair[:flair_css_class]} to CHAOS"

  @removed[flair[:flair_css_class]] += 1

  @subreddit.set_flair(
    Redd::Models::User.new(nil, name: flair[:user]),
    'Team Chaos',
    css_class: 'CHAOS-wagon'
  )
end

load_flairs after: arguments[:after]

counts = @removed
  .map { |flair, count| [count, flair].join(' ') }
  .join(', ')

puts "Removed: #{counts}"
