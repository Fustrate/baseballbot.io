class RedditController < ApplicationController
  # identity:  initially find the account name
  # edit:      update game chats
  # modconfig: update sidebar
  # modflair:  manage flair templates (unused)
  # modposts:  sticky, flair game chats
  # read:      used for updating game chats
  # submit:    post game chats
  # wikiread:  read settings from a sub's /wiki/baseballbot
  AUTH_SCOPE = %i(identity edit modconfig modflair modposts read submit
                  wikiread)

  def index
  end

  def authenticate
    if params[:error]
      flash[:error] = "Reddit returned an error: #{params[:error]}"
      redirect_to :root
    elsif params[:state] && params[:code]
      finish_authentication
    else
      redirect_to_reddit
    end
  end

  def finish_authentication
    fail 'Invalid state!' unless params[:state] == session[:state]

    save_account reddit.authorize! params[:code]

    redirect_to :root
  end

  def redirect_to_reddit
    session[:state] = SecureRandom.urlsafe_base64
    auth_url = reddit.auth_url session[:state], AUTH_SCOPE, :permanent

    redirect_to auth_url, status: 301
  end

  def reddit
    @reddit ||= Redd.it :web,
                        ENV['REDDIT_CLIENT_ID'],
                        ENV['REDDIT_SECRET'],
                        ENV['REDDIT_REDIRECT_URI']
  end

  def save_account(access)
    reddit.with(access) do |client|
      client.refresh_access! if access.expired?

      Account.create(
        name: client.me.name,
        scope: AUTH_SCOPE,
        access_token: access.access_token,
        refresh_token: access.refresh_token,
        expires_at: access.expires_at
      )
    end
  end
end
