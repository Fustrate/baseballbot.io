# frozen_string_literal: true

module Slack
  class CommandsController < ApplicationController
    before_action :verify_slack_signature

    def gdt
      render plain: 'Okay', status: 200
    end

    protected

    def verify_slack_signature
      raise 'Invalid signature' unless Slack::VerifySignature.valid?
    end
  end
end
