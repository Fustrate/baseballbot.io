# frozen_string_literal: true

json.call gamechat, *%i[
  id post_at starts_at status title post_id game_pk created_at updated_at
]

json.subreddit gamechat.subreddit, *%i[id name team_code]
