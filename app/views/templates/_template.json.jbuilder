# frozen_string_literal: true

json.call template, :id, :type, :body

unless local_assigns[:subreddit] == false
  json.subreddit template.subreddit, :id, :name
end
