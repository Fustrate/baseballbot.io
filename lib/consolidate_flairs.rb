# frozen_string_literal: true

require_relative 'default_bot'

@changes = { 'old classes' => 'new classes' }

@bot = DefaultBot.create(purpose: 'Merge Flairs', account: 'BaseballBot')
@subreddit = @bot.session.subreddit('baseball')

def load_flairs(after: nil)
  puts "Loading flairs#{after ? " after #{after}" : ''}"

  res = @subreddit.client
    .get('/r/baseball/api/flairlist', after: after, limit: 1000)
    .body

  res[:users].each { |flair| process_flair(flair) }

  return unless res[:next]

  sleep 5

  load_flairs after: res[:next]
end

def process_flair(flair)
  return unless @changes[flair[:flair_css_class]]

  puts "\tChanging #{flair[:user]} from #{flair[:flair_css_class]} " \
       "to #{@changes[flair[:flair_css_class]]}"

  @subreddit.set_flair(
    Redd::Models::User.new(nil, name: flair[:user]),
    flair[:flair_text],
    css_class: @changes[flair[:flair_css_class]]
  )
end

load_flairs after: ARGV[0]
