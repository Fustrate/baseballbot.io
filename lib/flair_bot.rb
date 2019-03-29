# frozen_string_literal: true

require_relative 'default_bot'

# A bot to iterate over pages of flairs
class FlairBot
  def initialize(purpose:, subreddit:)
    @bot = DefaultBot.create(purpose: purpose)

    @name = subreddit
    @subreddit = @bot.session.subreddit(@name)
  end

  def run(after: nil)
    @bot.with_reddit_account(@subreddit.account.name) do
      load_flair_page(after: after)
    end
  end

  protected

  def load_flair_page(after:)
    puts "Loading flairs#{after ? " after #{after}" : ''}"

    res = @subreddit.client
      .get("/r/#{@name}/api/flairlist", after: after, limit: 1000)
      .body

    res[:users].each { |flair| process_flair(flair) }

    return unless res[:next]

    sleep 5

    load_flair_page after: res[:next]
  end

  def process_flair(_flair); end
end
