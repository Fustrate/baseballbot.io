# frozen_string_literal: true

require_relative 'flair_bot'

class FlairCounts < FlairBot
  def initialize
    raise 'Please enter a subreddit name' unless ARGV[0]

    super(purpose: 'Flair Stats', subreddit: ARGV[0])

    @counts = Hash.new { |h, k| h[k] = 0 }
  end

  def run(after: nil)
    super

    @counts.each { |name, count| puts "\"#{name}\",#{count}" }
  end

  protected

  def process_flair(flair)
    @counts[flair[:flair_css_class]] += 1
  end
end

# We can't restart this, so start from the beginning
FlairCounts.new.run
