# frozen_string_literal: true
class AccountsController < ApplicationController
  # identity:  initially find the account name
  # edit:      update game chats
  # modconfig: update sidebar
  # modflair:  manage flair templates
  # flair:     assign flair to self and own submissions
  # modposts:  sticky, flair game chats
  # read:      used for updating game chats
  # submit:    post game chats
  # wikiread:  read settings from a sub's /wiki/baseballbot
  AUTH_SCOPE = %i(identity edit modconfig modflair modposts read submit
                  wikiread flair).freeze

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

  protected

  def finish_authentication
    raise 'Invalid state!' unless params[:state] == session[:state]

    save_account reddit.authorize! params[:code]

    redirect_to :root
  end

  def redirect_to_reddit
    session[:state] = SecureRandom.urlsafe_base64

    auth_url = Redd.url(
      client_id: Rails.application.secrets.reddit['client_id'],
      redirect_uri: Rails.application.secrets.reddit['redirect_uri'],
      state: session[:state],
      scope: AUTH_SCOPE,
      response_type: 'code',
      duration: 'permanent'
    )

    redirect_to auth_url, status: 301
  end

  def save_account(access)
    reddit.with(access) do |client|
      client.refresh_access! if access.expired?

      username = client.me.name

      existing = Account.where('LOWER(name) = ?', username.downcase).first

      if existing
        existing.update(
          scope: AUTH_SCOPE,
          access_token: access.access_token,
          refresh_token: access.refresh_token,
          expires_at: access.expires_at
        )

        existing
      else
        Account.create(
          id: Account.order('id DESC').limit(1).pluck(:id)[0] + 1,
          name: username,
          scope: AUTH_SCOPE,
          access_token: access.access_token,
          refresh_token: access.refresh_token,
          expires_at: access.expires_at
        )
      end
    end
  end
end
