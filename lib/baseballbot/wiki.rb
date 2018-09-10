# frozen_string_literal: true

class Baseballbot
  module Subreddits
    def load_wiki_page(name)
      subreddit.wiki_page(name)
    end
  end
end
