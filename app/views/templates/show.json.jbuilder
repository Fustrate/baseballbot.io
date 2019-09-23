# frozen_string_literal: true

json.call @template, :id, :type, :body

json.subreddit @template.subreddit, :id, :name
