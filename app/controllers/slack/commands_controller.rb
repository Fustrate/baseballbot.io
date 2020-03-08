# frozen_string_literal: true

module Slack
  class CommandsController < ApplicationController
    before_action :verify_slack_signature

    # We don't need CSRF protection here
    protect_from_forgery with: :null_session

    def gdt
      render json: Slack::Commands::GDT.call, status: 200
    end

    protected

    def verify_slack_signature
      Slack::VerifySignature.verify!
    end
  end
end
