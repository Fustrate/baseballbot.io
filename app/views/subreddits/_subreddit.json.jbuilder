# frozen_string_literal: true

json.call subreddit, :id, :name, :options

unless local_assigns[:templates] == false
  json.templates(subreddit.templates) do |template|
    json.call template, :id, :type, :body
  end
end
