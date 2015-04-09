require_relative 'baseballbot'

bot = Baseballbot.new(
  reddit: {
    user_agent: 'Baseballbot by /u/Fustrate',
    client_id: ENV['REDDIT_CLIENT_ID'],
    secret: ENV['REDDIT_SECRET'],
    redirect_uri: ENV['REDDIT_REDIRECT_URI']
  },
  db: {
    user: ENV['PG_USERNAME'],
    dbname: ENV['PG_DATABASE'],
    password: ENV['PG_PASSWORD']
  },
  user_agent: 'BaseballBot by /u/Fustrate - Messages'
)

GID = /(?:gid_)?(\d{4}_\d{2}_\d{2}_[a-z]{6}_[a-z]{6}_\d)/

client = bot.clients['BaseballBot']
account = bot.accounts.select { |_, a| a.name == 'BaseballBot' }.values.first

client.access = account.access
bot.refresh_client!(client) if account.access.expired?

client.my_messages('unread', false, limit: 10).each do |pm|
  next unless pm.subject =~ /(?:game ?(?:thread|chat|day)|gdt)/i
  next unless pm.body =~ %r{(?:redd\.it|/comments)/([a-z0-9]{6})}

  post_id = Regexp.last_match[1]

  submission = client.from_fullname("t3_#{post_id}").first

  if submission[:selftext] =~ GID
    subreddit = submission[:subreddit].downcase
    gid = Regexp.last_match[1]

    bot.redis.hset gid, subreddit, post_id
  end

  pm.mark_as_read
end
