# frozen_string_literal: true

json.call subreddit, :id, :name

# jbuilder doesn't format nested keys
json.options(
  subreddit.options.deep_transform_keys { |key| key.to_s.camelize(:lower) }
)

unless local_assigns[:templates] == false
  json.templates(subreddit.templates) do |template|
    json.call template, :id, :type, :body
  end
end

json.abbreviation @api.team(subreddit.team_id).abbreviation

json.account subreddit.account, :id, :name
