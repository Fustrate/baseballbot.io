class Account < ActiveRecord::Base
  # Use this method to make sure we refresh expired tokens and save the new ones
  def with_access
    return unless block_given?

    reddit.with(access) do |client|
      if access.expired?
        client.refresh_access!

        update access_token: access_token,
               refresh_token: refresh_token,
               expires_at: expires_at
      end

      yield client
    end
  end

  def access
    @access ||= Redd::Access.new(
      access_token: access_token,
      refresh_token: refresh_token,
      scope: scope.join(','),
      expires_at: expires_at
    )
  end

  def reddit
    @reddit ||= Redd.it :web,
                        ENV['REDDIT_CLIENT_ID'],
                        ENV['REDDIT_SECRET'],
                        ENV['REDDIT_REDIRECT_URI']
  end
end
