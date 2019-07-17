# frozen_string_literal: true

module Slack
  class VerifySignature
    VERSION = 'v0'

    # Returns true if the signature coming from Slack is valid.
    def self.verify!(team_id: nil)
      @team_id = team_id || Current.params[:team_id]

      ensure_valid_parameters!

      digest = OpenSSL::Digest::SHA256.new
      signature_base = [VERSION, timestamp, body].join(':')
      hex_hash = OpenSSL::HMAC.hexdigest(digest, signing_secret, signature_base)
      computed_signature = [VERSION, hex_hash].join('=')

      return if computed_signature == signature

      raise 'Invalid slack signature'
    end

    def self.ensure_valid_parameters!
      raise 'No team ID' unless @team_id

      raise 'No slack signing secret' unless signing_secret

      raise 'No slack request timestamp' unless timestamp

      raise 'No slack signature' unless signature
    end

    # Request timestamp.
    def self.timestamp
      @timestamp ||= Current.request.headers['X-Slack-Request-Timestamp']
    end

    # The signature is created by combining the signing secret with the body of
    # the request Slack is sending using a standard HMAC-SHA256 keyed hash.
    def self.signature
      @signature ||= Current.request.headers['X-Slack-Signature']
    end

    # Request body.
    def self.body
      @body ||= Current.request.raw_post
    end

    # Returns true if the signature coming from Slack has expired.
    def self.expired?
      timestamp.nil? || (Time.now.to_i - timestamp.to_i).abs > 300
    end

    def self.signing_secret
      Rails.application.credentials.dig(
        :"slack_#{@team_id}",
        :signing_secret
      )
    end
  end
end
