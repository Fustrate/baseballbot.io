# frozen_string_literal: true

# Accounts are used to run game threads and update sidebars - see `SessionsController` for moderator login
class AccountsController < ApplicationController
  # edit:             update game threads
  # flair:            assign flair to self and own submissions
  # history:          user comment/submission history
  # identity:         initially find the account name
  # modconfig:        update sidebar
  # modflair:         manage flair templates
  # modmail:          read & archive modmail
  # modnote:          make notes about users
  # modposts:         sticky, flair game threads
  # privatemessages:  read and sent PMs
  # read:             used for updating game threads
  # structuredstyles: new reddit widgets
  # submit:           post game threads
  # wikiread:         read settings from a sub's /wiki/baseballbot
  AUTH_SCOPE = %i[
    edit flair history identity modconfig modflair modmail modnote modposts privatemessages read structuredstyles submit
    wikiread
  ].freeze

  # def index; end

  # def show; end

  # def new; end

  # def edit; end

  # def create; end

  # def update; end

  # def destroy; end

  def authenticate
    if params[:error]
      flash[:error] = "Reddit returned an error: #{params[:error]}"
      redirect_to :app
    elsif params[:state] && params[:code]
      finish_authentication
    else
      redirect_to_reddit
    end
  end

  protected

  def finish_authentication
    raise UserError, 'Invalid state!' unless params[:state] == session[:state]

    save_account

    flash[:success] = t('authentication.success')

    redirect_to :app
  rescue Redd::AuthenticationError
    flash[:error] = t('authentication.invalid_token')

    redirect_to :app
  end

  def redirect_to_reddit
    session[:state] = SecureRandom.urlsafe_base64

    auth_url = Redd.url(
      client_id: Rails.application.credentials.dig(:reddit, :client_id),
      redirect_uri: Rails.application.credentials.dig(:reddit, :redirect_uri),
      response_type: 'code',
      state: session[:state],
      scope: AUTH_SCOPE,
      duration: 'permanent'
    )

    redirect_to auth_url, status: :moved_permanently, allow_other_host: true
  end

  def save_account
    reddit_session = Redd.it(
      code: params[:code],
      client_id: Rails.application.credentials.dig(:reddit, :client_id),
      secret: Rails.application.credentials.dig(:reddit, :secret),
      redirect_uri: Rails.application.credentials.dig(:reddit, :redirect_uri)
    )

    # reddit_session.client.refresh if reddit_session.client.access.expired?

    create_or_update_account(reddit_session)
  end

  def create_or_update_account(reddit_session)
    name = reddit_session.me.name
    expires_in = reddit_session.client.access.expires_in

    existing = Account.where('LOWER(name) = ?', name.downcase).first

    if existing
      update_existing_account(existing, reddit_session, expires_in)

      existing
    else
      create_new_account(name, reddit_session, expires_in)
    end
  end

  def update_existing_account(account, reddit_session, expires_in)
    account.update(
      scope: AUTH_SCOPE,
      access_token: reddit_session.client.access.access_token,
      refresh_token: reddit_session.client.access.refresh_token,
      expires_at: Time.zone.now + expires_in - 10.seconds
    )
  end

  def create_new_account(name, reddit_session, expires_in)
    Account.create(
      name:,
      scope: AUTH_SCOPE,
      access_token: reddit_session.client.access.access_token,
      refresh_token: reddit_session.client.access.refresh_token,
      expires_at: Time.zone.now + expires_in - 10.seconds
    )
  end
end
