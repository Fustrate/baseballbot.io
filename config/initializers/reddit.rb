# frozen_string_literal: true
module Redd
  class << self
    def url(client_id:, redirect_uri:, response_type: 'code', state: '', scope: ['identity'], duration: 'temporary')
      'https://www.reddit.com/api/v1/authorize?' + URI.encode_www_form(
        client_id: client_id,
        redirect_uri: redirect_uri,
        state: state,
        scope: scope.join(','),
        response_type: response_type,
        duration: duration
      )
    end
  end
end

def reddit
  @reddit ||= Redd.it(
    :web,
    Rails.application.secrets.reddit['client_id'],
    Rails.application.secrets.reddit['secret'],
    Rails.application.secrets.reddit['redirect_uri']
  )
end
