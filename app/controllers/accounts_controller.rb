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
  AUTH_SCOPE = %i[
    identity edit modconfig modflair modposts read submit wikiread flair
  ].freeze

  def index
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
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

    save_account

    flash[:success] = 'Your account is now active for use with BaseballBot.'

    redirect_to :root
  end

  def redirect_to_reddit
    session[:state] = SecureRandom.urlsafe_base64

    auth_url = Redd.url(
      client_id: reddit_config['client_id'],
      redirect_uri: reddit_config['redirect_uri'],
      response_type: 'code',
      state: session[:state],
      scope: AUTH_SCOPE,
      duration: 'permanent'
    )

    redirect_to auth_url, status: :moved_permanently
  end

  def save_account
    session = Redd.it(
      code: params[:code],
      client_id: reddit_config['client_id'],
      secret: reddit_config['secret'],
      redirect_uri: reddit_config['redirect_uri']
    )

    # session.client.refresh if session.client.access.expired?

    create_or_update_account(session)
  end

  def create_or_update_account(session)
    name = session.me.name
    expires_in = session.client.access.expires_in

    existing = Account.where('LOWER(name) = ?', name.downcase).first

    if existing
      update_existing_account(existing, session, expires_in)

      existing
    else
      create_new_account(name, session, expires_in)
    end
  end

  def update_existing_account(account, session, expires_in)
    account.update(
      scope: AUTH_SCOPE,
      access_token: session.client.access.access_token,
      refresh_token: session.client.access.refresh_token,
      expires_at: Time.zone.now + expires_in - 10.seconds
    )
  end

  def create_new_account(name, session, expires_in)
    Account.create(
      id: Account.order('id DESC').limit(1).pluck(:id)[0] + 1,
      name: name,
      scope: AUTH_SCOPE,
      access_token: session.client.access.access_token,
      refresh_token: session.client.access.refresh_token,
      expires_at: Time.zone.now + expires_in - 10.seconds
    )
  end

  def reddit_config
    @reddit_config ||= Rails.application.config_for(:reddit)
  end
end
