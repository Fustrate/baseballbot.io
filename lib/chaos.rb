# frozen_string_literal: true

require_relative 'default_bot'

class Chaos
  def initialize
    process_arguments

    @bot = DefaultBot.create(purpose: 'Chaos Flairs', account: 'BaseballBot')
    @subreddit = @bot.session.subreddit('baseball')

    @removed = Hash.new { |h, k| h[k] = 0 }
  end

  def run
    puts "Removing #{@remove_flairs.join(', ')}"

    load_flairs after: ARGV[1]

    counts = @removed.map { |flair, count| [count, flair].join(' ') }

    puts "Removed: #{counts.join(', ')}"
  end

  protected

  def process_arguments
    unless ARGV[0] && ARGV.count < 3
      raise 'Pass 1-2 arguments: chaos.rb SFG-wagon,CHC-wagon [t2_123456]'
    end

    @remove_flairs = ARGV[0].split(',')

    raise 'Pass a flair class as an argument.' unless @remove_flairs&.any?
  end

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
end

Chaos.new.run
