# frozen_string_literal: true

module Slack
  class VerifySignature
    VERSION = 'v0'

    # Returns true if the signature coming from Slack is valid.
    def self.valid?
      return false unless signing_secret

      digest = OpenSSL::Digest::SHA256.new
      signature_basestring = [VERSION, timestamp, body].join(':')
      hex_hash = OpenSSL::HMAC.hexdigest(digest, signing_secret, signature_basestring)
      computed_signature = [VERSION, hex_hash].join('=')

      computed_signature == signature
    end

    # Request timestamp.
    def self.timestamp
      @timestamp ||= request.headers['X-Slack-Request-Timestamp']
    end

    # The signature is created by combining the signing secret with the body of the request
    # Slack is sending using a standard HMAC-SHA256 keyed hash.
    def self.signature
      @signature ||= request.headers['X-Slack-Signature']
    end

    # Request body.
    def self.body
      @body ||= request.raw_post
    end

    # Returns true if the signature coming from Slack has expired.
    def self.expired?
      timestamp.nil? || (Time.now.to_i - timestamp.to_i).abs > 300
    end

    def self.signing_signature
      Rails.application.config_for(:slack_dodgers)['signing_secret']
    end
  end
end
