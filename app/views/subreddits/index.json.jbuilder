# frozen_string_literal: true

json.data(@subreddits) do |subreddit|
  json.call subreddit, :id, :name

  # jbuilder doesn't format nested keys
  json.options(
    subreddit.options.deep_transform_keys { |key| key.to_s.camelize(:lower) }
  )

  json.abbreviation @api.team(subreddit.team_id).abbreviation

  json.account subreddit.account, :id, :name
end
