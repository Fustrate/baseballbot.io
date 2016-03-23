# frozen_string_literal: true
def reddit
  @reddit ||= Redd.it :web,
                      Rails.application.secrets.reddit['client_id'],
                      Rails.application.secrets.reddit['secret'],
                      Rails.application.secrets.reddit['redirect_uri']
end
