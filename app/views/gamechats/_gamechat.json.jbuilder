# frozen_string_literal: true

json.call gamechat, *%i(id gid post_at starts_at status title post_id)

json.subreddit do
  json.call gamechat.subreddit, *%i(id name team_code)
end
