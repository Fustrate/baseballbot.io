# frozen_string_literal: true

require_relative 'default_bot'

require 'uri'
require 'net/http'
require 'net/https'
require 'json'

SLACK_HOOK_ID = ENV['DODGERS_SLACK_HOOK_ID']

class ModQueue
  def initialize
    @bot = DefaultBot.create(purpose: 'Mod Queue', account: 'DodgerBot')
    @subreddit = @bot.session.subreddit('Dodgers')

    @uri = URI.parse("https://hooks.slack.com/services/#{SLACK_HOOK_ID}")

    @https = Net::HTTP.new(@uri.host, @uri.port)
    @https.use_ssl = true
  end

  def run!(retry_on_failure: true)
    @subreddit.modqueue(limit: 10).each { |item| process_item item }
  rescue Redd::APIError
    return unless retry_on_failure

    puts 'Service unavailable: waiting 30 seconds to retry.'

    sleep 30

    run!(retry_on_failure: false)
  rescue => e
    Honeybadger.notify(e)
  end

  protected

  def process_item(item)
    return if @bot.redis.hget('dodgers_mod_queue', item.name)

    send_to_slack slack_message(item)

    @bot.redis.hset 'dodgers_mod_queue', item.name, 1

    # Don't flood the slack channel
    sleep(5)
  end

  def slack_message(item)
    {
      text: "*#{item.author.name}* was reported for:",
      attachments: [
        body_attachment(item),
        mod_queue_reason(item)
      ]
    }
  end

  def body_attachment(item)
    {
      text: item.body,
      title: item.link_title,
      title_link: "https://www.reddit.com#{item.permalink}"
    }
  end

  def mod_queue_reason(item)
    reports = item.mod_reports + item.user_reports
    reasons = reports.map { |reason, number| "#{reason} (#{number})" }

    {
      text: reports.any? ? "Reports: #{reasons.join(', ')}" : 'Spam?'
    }
  end

  def send_to_slack(message)
    req = Net::HTTP::Post.new(@uri.path, 'Content-Type' => 'application/json')
    req.body = message.to_json

    res = @https.request(req)

    return if res.code.to_i == 200

    raise 'Uh oh!'
  end
end

ModQueue.new.run!