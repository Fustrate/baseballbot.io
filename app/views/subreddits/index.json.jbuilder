# frozen_string_literal: true

json.collection!(
  @subreddits,
  partial: 'subreddits/subreddit',
  as: :subreddit,
  locals: {
    templates: false
  }
)
