# frozen_string_literal: true

require_relative 'default_bot'

@bot = DefaultBot.create(purpose: 'Around the Horn', account: 'BaseballBot')
@subreddit = @bot.session.subreddit('baseball')

title = Time.now.strftime '[General Discussion] Around the Horn - %-m/%-d/%y'
text = @subreddit.wiki_page('ath').content_md.split(/\r?\n-{3,}\r?\n/)[1].strip

submission = @subreddit.submit(title, text: text, sendreplies: false)

submission.make_sticky(slot: 1)
submission.set_suggested_sort 'new'
