# frozen_string_literal: true

module Slack
  class VerifySignature < ApplicationService
    VERSION = 'v0'

    # Returns true if the signature coming from Slack is valid.
    def call(team_id: nil)
      @team_id = team_id || Current.params[:team_id]

      ensure_valid_parameters!

      digest = OpenSSL::Digest.new('SHA256')
      signature_base = [VERSION, timestamp, body].join(':')
      hex_hash = OpenSSL::HMAC.hexdigest(digest, signing_secret, signature_base)
      computed_signature = [VERSION, hex_hash].join('=')

      return if computed_signature == signature

      raise UserError, 'Invalid slack signature'
    end

    protected

    def ensure_valid_parameters!
      raise UserError, 'No team ID' unless @team_id

      raise UserError, 'No slack signing secret' unless signing_secret

      raise UserError, 'No slack request timestamp' unless timestamp

      raise UserError, 'No slack signature' unless signature
    end

    # Request timestamp.
    def timestamp
      @timestamp ||= Current.request.headers['X-Slack-Request-Timestamp']
    end

    # The signature is created by combining the signing secret with the body of
    # the request Slack is sending using a standard HMAC-SHA256 keyed hash.
    def signature
      @signature ||= Current.request.headers['X-Slack-Signature']
    end

    # Request body.
    def body
      @body ||= Current.request.raw_post
    end

    # Returns true if the signature coming from Slack has expired.
    def expired?
      timestamp.nil? || (Time.now.to_i - timestamp.to_i).abs > 300
    end

    def signing_secret
      Rails.application.credentials.dig(:"slack_#{@team_id}", :signing_secret)
    end
  end
end
