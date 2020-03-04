# frozen_string_literal: true

json.call @subreddit, :id, :name

# jbuilder doesn't format nested keys
json.options(
  @subreddit.options.deep_transform_keys { |key| key.to_s.camelize(:lower) }
)

json.templates(@subreddit.templates) do |template|
  json.call template, :id, :type, :body
end

abbreviation = @api.team(@subreddit.team_id).abbreviation if @subreddit.team_id

json.abbreviation abbreviation

json.account @subreddit.account, :id, :name
