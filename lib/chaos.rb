# frozen_string_literal: true

require_relative 'flair_bot'

class Chaos < FlairBot
  def initialize
    unless ARGV[0] && ARGV.count < 3
      raise 'Pass 1-2 arguments: chaos.rb SFG-wagon,CHC-wagon [t2_123456]'
    end

    @remove_flairs = ARGV[0].split(',')

    raise 'Pass a flair class as an argument.' unless @remove_flairs&.any?

    super(purpose: 'Chaos Flairs', subreddit: 'baseball')

    @removed = Hash.new { |h, k| h[k] = 0 }
  end

  def run(after: nil)
    puts "Removing #{@remove_flairs.join(', ')}"

    super

    counts = @removed.map { |flair, count| [count, flair].join(' ') }

    puts "Removed: #{counts.join(', ')}"
  end

  protected

  def process_flair(flair)
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

Chaos.new.run after: ARGV[1]
