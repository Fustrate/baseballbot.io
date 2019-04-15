# frozen_string_literal: true

module Slack
  class CommandsController < ApplicationController
    before_action :verify_slack_signature

    # We don't need CSRF protection here
    protect_from_forgery with: :null_session

    def gdt
      # params[:command] => '/gdt
      # params[:text] => 'test'

      render plain: 'Okay', status: 200
    end

    protected

    def verify_slack_signature
      raise 'Invalid signature' unless Slack::VerifySignature.valid?
    end
  end
end
