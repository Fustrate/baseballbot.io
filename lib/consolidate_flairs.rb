# frozen_string_literal: true

require_relative 'default_bot'

class ConsolidateFlairs
  CHANGES = {
    'old classes' => 'new classes'
  }.freeze

  def initialize
    @bot = DefaultBot.create(purpose: 'Merge Flairs', account: 'BaseballBot')
    @subreddit = @bot.session.subreddit('baseball')
  end

  def run
    load_flairs after: ARGV[0]
  end

  protected

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
    return unless CHANGES[flair[:flair_css_class]]

    puts "\tChanging #{flair[:user]} from #{flair[:flair_css_class]} " \
         "to #{CHANGES[flair[:flair_css_class]]}"

    @subreddit.set_flair(
      Redd::Models::User.new(nil, name: flair[:user]),
      flair[:flair_text],
      css_class: CHANGES[flair[:flair_css_class]]
    )
  end
end

ConsolidateFlairs.new.run
