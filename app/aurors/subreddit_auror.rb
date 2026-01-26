# frozen_string_literal: true

class SubredditAuror < Auror::Authorizer
  def update? = Current.user.type == 'admin' || Current.user.subreddit_ids.include?(resource.id)
end
